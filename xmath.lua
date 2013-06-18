local ffi = require 'ffi'

local xmath = {__index=math}
setmetatable(xmath, xmath)

local exp = math.exp
local log = math.log

local log1p
pcall(function()
  ffi.cdef 'double log1p(double);'
  log1p = ffi.C.log1p
end)
if not log1p then
  -- Translated from http://www.johndcook.com/cpp_log_one_plus_x.html
  function log1p(x)
    if x <= -1.0 then
      error("Invalid input argument (" .. tostring(x) .. "); must be greater than -1.0")
    end
    if math.abs(x) > 1e-4 then
      -- x is large enough that the obvious evaluation is OK
      return log(1.0 + x)
    end

    -- Use Taylor approx. log(1 + x) = x - x^2/2 with error roughly x^3/3
    -- Since ||x|| < 10^-4, ||x||^3 < 10^-12, relative error less than 10^-8
    return (-0.5*x + 1.0)*x;
  end
end
xmath.log1p = log1p

local function logit(x)
  return log(x) - log1p(-x)
end
xmath.logit = logit

local function softmax(es, n, dst)
  n = n or #es
  dst = dst or {}
  local s, c = 0, 0
  for i = 1, n do
    local y = exp(es[i])
    dst[i] = y
    y = y - c
    local t = s + y
    c = (t - s) - y
    s = t
  end
  for i = 1, n do
    dst[i] = dst[i] / s
  end
  return dst
end

xmath.softmax = softmax

return xmath
