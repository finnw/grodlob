local ffi = require 'ffi'

local smtFfiLib = {}
local ffiLib = {}

function smtFfiLib:__call(m)
  local libName = self[m]
  if libName then return ffi.load(libName) end
  return ffi.C
end

setmetatable(ffiLib, smtFfiLib)
return ffiLib
