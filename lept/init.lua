local ffi = require 'ffi'
local liblept = require 'liblept'

local clLept = getmetatable(liblept).__index

local lept = {}

do
  local ppixel = ffi.new 'uint32_t[1]'
  function lept.composeRGBPixel(rval, gval, bval)
    local status = clLept.composeRGBPixel(rval, gval, bval, ppixel)
    assert(status == 0)
    return ppixel[0]
  end
end

do
  local prval = ffi.new 'int32_t[1]'
  local pgval = ffi.new 'int32_t[1]'
  local pbval = ffi.new 'int32_t[1]'
  function lept.convertHSVToRGB(hval, sval, vval)
    clLept.convertHSVToRGB(hval, sval, vval, prval, pgval, pbval)
    return prval[0], pgval[0], pbval[0]
  end
end

do
  local phval = ffi.new 'int32_t[1]'
  local psval = ffi.new 'int32_t[1]'
  local pvval = ffi.new 'int32_t[1]'
  function lept.convertRGBToHSV(rval, gval, bval)
    clLept.convertRGBToHSV(rval, gval, bval, phval, psval, pvval)
    return phval[0], psval[0], pvval[0]
  end
end

return lept
