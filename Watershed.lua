local FPix = require 'lept.FPix'
local ffi = require 'ffi'
local liblept = require 'liblept'
local point16 = require 'point16'

local bor = bit.bor
local max = math.max

local mWatershed = {}
local Watershed = setmetatable({}, mWatershed)
local iWatershed = {__index=Watershed}

local pixelsort = require 'pixelsort_cdef'
local C = ffi.C

ffi.cdef [[

struct wshed_handle
{
    struct wshed *targets[1];
};

]]

local ctHandle
local iHandle = {}

local EMPTY = {}
local NaN = math.huge - math.huge

function mWatershed:__call(fpix)
  local handle = ctHandle()
  self = { handle=handle, fpix=fpix }
  handle.targets[0] = pixelsort.wshed_create(fpix:toPFPix())
  setmetatable(self, iWatershed)
  return self
end

do
  local pixSeg = ffi.new 'struct wsGridCell *[1]'
  local mergePair = ffi.new 'struct wsGridCell *[2]'
  local mrBuf = ffi.new 'enum mergeResult[1]'
  function Watershed:fill(shouldMerge)
    local mr = nil
    while true do
      local fpr =
        pixelsort.wshed_fill(self.handle.targets[0], pixSeg, mergePair, mr)
      mr = nil
      if fpr == C.FPR_DONE then
        break
      elseif fpr == C.FPR_NEEDSMERGE then
        mrBuf[0] = shouldMerge(pixSeg[0], mergePair[0], mergePair[1])
        mr = mrBuf
        assert(mr[0] ~= C.MR_YIELD)
      end
    end
  end
end

function Watershed.confirmMerge(seg1, seg2)
  pixelsort.wshed_merge(seg1, seg2)
  return C.MR_RETRY
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
-- May need to be translated to C
--[[
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
--]]

--[[
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
--]]

function iHandle:__gc()
  pixelsort.wshed_free(self.targets[0])
end

ctHandle = ffi.metatype('struct wshed_handle', iHandle)

return Watershed
