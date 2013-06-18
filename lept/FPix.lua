local ffi = require 'ffi'
local liblept = require 'liblept'

local mFPix = {}
local FPix = {}
local iFPix = {__index=FPix}
local ctPFPix = ffi.typeof 'struct FPix *'
local ctFPix

local clLept = getmetatable(liblept).__index

local function toPFPix(fpix)
  if fpix == nil then
    return nil
  elseif ffi.istype(fpix, ctFPix) then
    local pFPix = fpix.handles[0]
    if pFPix == nil then
      return nil
    else
      return pFPix
    end
  elseif ffi.istype(fpix, ctPFPix) then
    return fpix
  else
    error("Invalid FPix designator: " .. tostring(fpix), 3)
  end
end

function mFPix:__call(fpix)
  local pfpix = toPFPix(fpix)
  if not pfpix then return nil end
  self = ffi.new(ctFPix)
  self.handles[0] = clLept.fpixClone(pfpix)
  return self
end

function FPix:clone()
  return FPix(self.handles[0])
end

function FPix.create(width, height)
  local self = ffi.new(ctFPix)
  self.handles[0] = clLept.fpixCreate(width, height)
  return self
end

function FPix:getData()
  return clLept.fpixGetData(self.handles[0])
end

do
  local px, py = ffi.new 'int32_t[1]', ffi.new 'int32_t[1]'
  function FPix:getDimensions()
    local status = clLept.fpixGetDimensions(self.handles[0], px, py)
    assert(status == 0)
    return px[0], py[0]
  end

  local pMaxVal = ffi.new 'float[1]'
  function FPix:getMax()
    local status = clLept.fpixGetMax(self.handles[0], pMaxVal, px, py)
    assert(status == 0)
    return pMaxVal[0], px[0], py[0]
  end
end

FPix.getHandle = toPFPix

function FPix:getWpl()
  return clLept.fpixGetWpl(self.handles[0])
end

function iFPix:__gc()
  clLept.fpixDestroy(self.handles)
end

function iFPix:__tostring()
  local p = self.handles[0]
  if p == nil then return "<FPix @ NULL>" end
  local text = (p.text ~= nil) and string.format("%q", p.text) or "nil"
  return string.format("<FPix @ %p: w=%u; h=%u; wpl=%u; refcount=%u; xres=%d; yres=%d;  text=%s; data=%s>",
                       p, p.w, p.h, p.wpl, p.refcount, p.xres, p.yres, text, tostring(p.data))
end

iFPix.__unm = toPFPix

ctFPix = ffi.metatype('struct {struct FPix *handles[1];}', iFPix)

setmetatable(FPix, mFPix)

return FPix
