local ffi = require 'ffi'
local liblept = require 'liblept'

local mPta = {}
local Pta = setmetatable({}, mPta)
local iPta = {__index=Pta}

local ctPPta = ffi.typeof 'struct Pta *'

local PtaHost = {}
local iPtaHost = {__index=PtaHost}
local ctPtaHost, szPtHost

local clLept = getmetatable(liblept).__index

local nonNull
do
  local ctIntPtr = ffi.typeof 'intptr_t'
  function nonNull(p)
    if tonumber(ffi.cast(ctIntPtr, p)) == 0 then
      return nil
    else
      return p
    end
  end
end

local wrapperMap = setmetatable({}, {__mode='v'})
local function wrap(ppta)
  if not (ppta and nonNull(ppta)) then return nil end
  local host = ctPtaHost()
  host.handles[0] = ppta
  local key = ffi.string(host, szPtHost)
  local self = wrapperMap[key]
  if not self then
    self = {host = host}
    wrapperMap[key] = self
    setmetatable(self, iPta)
  end
  return self
end
Pta.wrap = wrap

local function toPPta(pta)
  if pta == nil then
    return nil
  elseif ffi.istype(ctPtaHost, pta) then
    return nonNull(pta.handles[0])
  elseif type(pta) == 'table' and getmetatable(pta) == iPta then
    return toPPta(pta.host)
  else
    error("Invalid Pta designator: " .. tostring(pta), 3)
  end
end
function Pta:addPt(x, y)
  return clLept.ptaAddPt(self.host.handles[0], x, y) == 0
end

function Pta.create(expectedSize)
  return wrap(clLept.ptaCreate(tonumber(expectedSize) or 64))
end

do
  local px = ffi.new 'float[2]'
  local py = px + 1

  function Pta:getPt(i)
    if clLept.ptaGetPt(self.host.handles[0], i, px, py) == 0 then
      return px[0], px[1]
    end
  end
end

function Pta:generatePolyLine(width, closeflag, removedups)
  return wrap(clLept.generatePtaPolyline(self.handles[0], tonumber(width) or 1, closeFlag and 1 or 0, removedups and 1 or 0))
end

function Pta.generateLine(x1, y1, x2, y2)
  return wrap(clLept.generatePtaLine(x1, y1, x2, y2))
end

function Pta:getCount()
  return clLept.ptaGetCount(self.host.handles[0])
end

function iPta:__len()
  return self:getCount()
end

function iPta:__tostring()
  local p = self.host.handles[0]
  if p == nil then return "<Pta @ NULL>" end
  local text = (p.text ~= nil) and string.format("%q", p.text) or "nil"
  return string.format("<Pta @ %p: n=%u; nalloc=%u; refcount=%u; x=%s; y=%s>",
                       p, p.n, p.nalloc, p.refcount, tostring(p.x), tostring(p.y))
end

function iPtaHost:__gc()
  clLept.ptaDestroy(self.handles)
end

local accessors = {}
PtaHost.index = {}

function iPta:__index(k)
  local acc = accessors[k]
  if acc then
    return acc(self)
  else
    return Pta[k] or self.host.index[k]
  end
end

--[[
function iPta:__tostring()
  local p = toPPix(self)
  if p == nil then return "<Pix @ NULL>" end
  local text = (p.text ~= nil) and string.format("%q", p.text) or "nil"
  return string.format("<Pix @ %p: w=%u; h=%u; d=%u; wpl=%u; refcount=%u; xres=%d; yres=%d; informat=%d; text=%s; colormap=%s; data=%s>",
                       p, p.w, p.h, p.d, p.wpl, p.refcount, p.xres, p.yres, p.informat, text, tostring(p.colormap), tostring(p.data))
end
--]]
ctPtaHost = ffi.metatype('struct {struct Pta *handles[1];}', iPtaHost)
szPtHost = ffi.sizeof(ctPtaHost)

setmetatable(Pta, mPta)

return Pta