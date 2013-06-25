local ffi = require 'ffi'
local ffiu = require 'ffiu'
local liblept = require 'liblept'

local assert, select = assert, select

local istype, new, ffi_string = ffi.istype, ffi.new, ffi.string

local nonNull = ffiu.nonNull

local mFPix = {}
local FPix = {}
local iFPix = {__index=FPix}
local ctPFPix = ffi.typeof 'struct FPix *'
local ctFPix, cbFPix

local clLept = getmetatable(liblept).__index

local wrapperMap = setmetatable({}, {__index='v'})

local function toPFPix(fpix)
  if fpix == nil then
    return nil
  elseif istype(ctFPix, fpix) then
    local pFPix = fpix.handles[0]
    if pFPix == nil then
      return nil
    else
      return pFPix
    end
  elseif istype(ctPFPix, fpix) then
    return fpix
  else
    error("Invalid FPix designator: " .. tostring(fpix), 3)
  end
end
FPix.toPFPix = toPFPix

local function wrap(pfpix, mode)
  if not nonNull(pfpix) then return nil end
  if istype(ctFPix, pfpix) then return pfpix end
  assert(istype(ctPFPix, pfpix), debug.traceback())
  local self = new(ctFPix)
  self.handles[0] = clLept.fpixClone(pfpix)
  if mode == 'unique' then return self end
  local key = ffi_string(self.handles, cbFPix)
  local fpix = wrapperMap[key]
  if fpix then
    self = fpix
  else
    wrapperMap[key] = self
  end
  return self
end

function mFPix:__call(pfpix, mode)
  return wrap(pfpix, mode)
end

function FPix.create(width, height)
  return wrap(clLept.fpixCreate(width, height), 'unique')
end

function FPix:getData()
  return clLept.fpixGetData(self.handles[0])
end

do
  local px, py = new 'int32_t[1]', new 'int32_t[1]'
  function FPix:getDimensions()
    local status = clLept.fpixGetDimensions(self.handles[0], px, py)
    assert(status == 0)
    return px[0], py[0]
  end

  local pMaxVal = new 'float[1]'
  function FPix:getMax()
    local status = clLept.fpixGetMax(self.handles[0], pMaxVal, px, py)
    assert(status == 0)
    return pMaxVal[0], px[0], py[0]
  end
end

do
  local pixelBuf = new 'float[1]'
  function FPix:getPixel(x, y)
    local res = clLept.fpixGetPixel(self.handles[0], x, y, pixelBuf)
    assert(res == 0, "failed to read pixel value")
    return pixelBuf[0]
  end
end

function FPix:getWpl()
  return clLept.fpixGetWpl(self.handles[0])
end

function iFPix:__gc()
  clLept.fpixDestroy(self.handles)
end

local accessors = {}
function accessors:w()
  return select(1, self:getDimensions())
end

function accessors:h()
  return select(2, self:getDimensions())
end

function iFPix:__index(k)
  local acc = accessors[k]
  if acc then
    return acc(self)
  else
    return FPix[k]
  end
end

function iFPix:__tostring()
  local p = self.handles[0]
  if p == nil then return "<FPix @ NULL>" end
  local text = (p.text ~= nil) and string.format("%q", p.text) or "nil"
  return string.format("<FPix @ %p: w=%u; h=%u; wpl=%u; refcount=%u; xres=%d; yres=%d;  text=%s; data=%s>",
                       p, p.w, p.h, p.wpl, p.refcount, p.xres, p.yres, text, tostring(p.data))
end

ctFPix = ffi.metatype('struct {struct FPix *handles[1];}', iFPix)
cbFPix = ffi.sizeof(ctFPix)

setmetatable(FPix, mFPix)

return FPix
