local ffi = require 'ffi'

local ffiu = {}

do
  local ctIntPtr = ffi.typeof 'intptr_t'
  function ffiu.nonNull(p)
    if tonumber(ffi.cast(ctIntPtr, p)) == 0 then
      return nil
    else
      return p
    end
  end
end

return ffiu