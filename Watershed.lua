local FPix = require 'lept.FPix'
local Segment = require 'Segment'
local UnionFind = require 'UnionFind'
local ffi = require 'ffi'
local liblept = require 'liblept'
local point16 = require 'point16'

local bor = bit.bor
local max = math.max

local mWatershed = {}
local Watershed = setmetatable({}, mWatershed)
local iWatershed = {__index=Watershed}

require 'pixelsort_cdef'

local C = ffi.C

local EMPTY = {}
local iWsBitmap = {}
local NaN = math.huge - math.huge

local ctPUI8 = ffi.typeof 'uint8_t *'
local ctPixelList = ffi.typeof 'struct pixel[?]'
local ctWsBitmap
local szPixel = ffi.sizeof 'struct pixel'

local function createPixelList(fpix)
  local numPixels = fpix.w * fpix.h
  local buffer = ffi.new(ctPixelList, numPixels)
  C.grod_genSortedListFromFPix(fpix:toPFPix(), buffer)
  return buffer, numPixels
end

local function fillPixel(self, rank, x, y, intensity, modes)
  modes = modes or EMPTY
  -- Most likely outcome is that we extend an existing segment
  local extResult = 'extended'
  local pgrow0 = self.pgrid[y]
  local uniqueNeighbor = nil
  for dy = -1,1 do
    local ny = y + dy
    if ny < 0 then goto BADROW end -- Avoid sparse access (for performance)
    local pgrow = self.pgrid[ny]
    if pgrow then
      for dx = -1,1 do
        if bor(dx, dy) ~= 0 then
          local nx = x + dx
          if nx < 0 then goto BADCOL end
          local np = pgrow[nx]
          if np and (np ~= true) then
            if (not uniqueNeighbor) or (uniqueNeighbor == np) then
              uniqueNeighbor = np:find()
            elseif (not modes.noMerge) and
                   self:shouldMerge(rank, x, y, intensity,
                                    uniqueNeighbor, np:find(), modes) then
              uniqueNeighbor = uniqueNeighbor:merge(np)
              pgrow[nx] = uniqueNeighbor
              self.pop = self.pop - 1
              extResult = 'merged'
            else
              -- We now know that cell [x,y] borders at least two distinct
              -- segments.  We now mark [x,y] as a boundary pixel.
              pgrow0[x] = true
              return 'edge'
            end
          end
::BADCOL::
        end
      end
    end
::BADROW::
  end
  local newP, result
  if uniqueNeighbor then
    newP = uniqueNeighbor:find()
    newP:add(Segment(x, y))
    self.maxMass = max(self.maxMass, newP.val.mass)
    result = extResult
  else
    newP = UnionFind(Segment(x, y))
    self.pop = self.pop + 1
    result = 'new'
  end
  pgrow0[x] = newP
  return result
end

function mWatershed:__call(fpix, config)
  config = config or EMPTY
  local pgrid = {}
  for y = 0, fpix.h-1 do
    local pgrow = {}
    for x = 0, fpix.w-1 do
      pgrow[x] = false
    end
    pgrid[y] = pgrow
  end
  local buffer, numPixels = createPixelList(fpix)
  self = {
    buffer=buffer, fpix=fpix, maxMass=0,
    numPixels=numPixels, pgrid=pgrid, pop=0
  }
  setmetatable(self, iWatershed)
  return self
end

function Watershed:fill(modes)
  modes = modes or EMPTY
  local buffer = self.buffer
  for j = 0, (modes.limit or self.numPixels)-1 do
    local x, y = buffer[j].x, buffer[j].y
    local fillResult = fillPixel(self, j+1, x, y, buffer[j].intensity, modes)
  end
end

-- Figure out which is the border segment (by probing key points on the
-- perimeter of the image until we find a segment of large enough mass.)
function Watershed:findBorder()
  if not self.borderP then
    local fpix = self.fpix
    local borderP, borderMass = nil, 5000
    for _, bx in ipairs {0, math.floor(fpix.width * .5), fpix.width - 1} do
      for _, by in ipairs {0, math.floor(fpix.height * .5), fpix.height - 1} do
        local p = self.pgrid[by][bx]
        if type(p) == 'table' then
          p = p:find()
          if p.val.mass > borderMass then
            borderP = p
            borderMass = p.val.mass
          end
        end
      end
    end
    self.borderP = borderP
  end
  return self.borderP
end

function Watershed:setSmallSegPriority(thres, val)
  thres = thres or 7
  val = val or 2.
  local buffer = self.buffer
  for j = 0, self.numPixels-1 do
    local x, y = buffer[j].x, buffer[j].y
    local pgrow = self.pgrid[y]
    local pebble = false
    for dy = -1,1 do
      local ny = y + dy
      local pgrow = self.pgrid[ny]
      if pgrow then
        for dx = -1,1 do
          if bor(dx, dy) ~= 0 then
            local nx = x + dx
            local np = pgrow[nx]
            if np and np ~= true then
              np = np:find()
              if np.val.mass < thres then
                pebble = true
                break
              end
            end
          end
        end
      end
      if pebble then break end
    end
    if pebble then
      buffer[j].intensity = buffer[j].intensity + val
    end
  end
end

-- Clear stray edge pixels and dead segments
function Watershed:prune(options)
  options = options or EMPTY
  local fillModes =
    setmetatable({
      noMerge=true, mayPruneCordon=true, keepDark=false
    }, {__index=options})
  local critMass = options.critMass or 20
  local buffer = self.buffer
  repeat
    local anyExtended = false
    local k = 0
    for j = 0, self.numPixels-1 do
      local x, y = buffer[j].x, buffer[j].y
      local pgrow = self.pgrid[y]
      local p = pgrow[x]
      local isEdge = true
      if p == true then
        local fillResult = fillPixel(self, NaN, x, y, NaN, fillModes)
        if fillResult == 'extended' then
          anyExtended = true
          isEdge = false
        end
      else
        p = p:find()
        pgrow[x] = p
        if p.val.mass >= critMass then
          p.val = p.val:withCritical(true)
        end
        isEdge = false
      end
      if isEdge then
        ffi.copy(buffer[k], buffer[j], szPixel)
        k = k + 1
      else
        local cordonKey = point16.fromXY(x, y)
        self.cordon[cordonKey] = nil
      end
    end
    self.numPixels = k
  until not anyExtended
end

function Watershed:shouldMerge(rank, x, y, intensity, p1, p2, modes)
  modes = modes or EMPTY
  if self.fpix:getPixel(x, y) > 0.9 then return true end
  return false
end

function Watershed:getRoots()
  local roots = {}
  for y, pgrow in pairs(self.pgrid) do
    for x, p in pairs(pgrow) do
      if p ~= true then
        p = p:find()
        pgrow[x] = p
        roots[p] = true
      end
    end
  end
  return roots
end

return Watershed
