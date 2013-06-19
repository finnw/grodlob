local ffi = require 'ffi'

local point16 = {}

local buffer = ffi.new "struct {int16_t x, y;}"

function point16.fromXY(x, y)
  buffer.x, buffer.y = x, y
  return ffi.string(buffer, 4)
end

function point16.toXY(p)
  ffi.copy(buffer, p, 4)
  return buffer.x, buffer.y
end

return point16
