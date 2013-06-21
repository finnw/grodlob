local ffi = require 'ffi'

local rawset, type = rawset, type
local copy = ffi.copy
local ffi_string = ffi.string

local max, min = math.max, math.min

local mSegment = {}
local Segment = setmetatable({}, mSegment)
local iSegment = {__index=Segment}

ffi.cdef [[
  struct segName
  {
    double mass;
    double minX, maxX, minY, maxY;
    double xSum, ySum;
    bool border;
  };
]]

local ctSegName = ffi.typeof 'struct segName'
local szSegName = ffi.sizeof(ctSegName)
local lIn, rIn, out = ctSegName(), ctSegName(), ctSegName()

local snFields = {
  mass=true,
  minX=true, maxX=true, minY=true, maxY=true,
  xSum=true, ySum=true,
  border=true,
}

local function doAdd(l, r)
  copy(lIn, l, szSegName)
  copy(rIn, r, szSegName)
  out.mass = lIn.mass + rIn.mass
  out.minX = min(lIn.minX, rIn.minX)
  out.maxX = max(lIn.maxX, rIn.maxX)
  out.minY = min(lIn.minY, rIn.minY)
  out.maxY = max(lIn.maxY, rIn.maxY)
  out.xSum = lIn.xSum + rIn.xSum
  out.ySum = lIn.ySum + rIn.ySum
  out.border = lIn.border or rIn.border
  return ffi_string(out, szSegName)
end

local function wrap(n)
  local result = {name=n}
  setmetatable(result, iSegment)
  return result
end

function mSegment:__call(x, y)
  out.mass = 1
  out.minX = x
  out.maxX = x
  out.minY = y
  out.maxY = y
  out.xSum = x
  out.ySum = y
  return wrap(ffi_string(out, szSegName))
end

function iSegment.__add(l, r)
  if type(l) ~= 'string' then l = l.name end
  if type(r) ~= 'string' then r = r.name end
  return wrap(doAdd(l, r))
end

function iSegment:__index(k)
  if k == 'cx' then
    local result = self.xSum / self.mass
    rawset(self, k, result)
    return result
  elseif k == 'cy' then
    local result = self.ySum / self.mass
    rawset(self, k, result)
    return result
  elseif k == 'width' then
    local result = self.maxX - self.minX + 1
    rawset(self, k, result)
    return result
  elseif k == 'height' then
    local result = self.maxY - self.minY + 1
    rawset(self, k, result)
    return result
  elseif snFields[k] then
    copy(lIn, self.name, szSegName)
    local result = lIn[k]
    rawset(self, k, result)
    return result
  else
    return Segment[k]
  end
end

function iSegment:__newindex(k)
  error "Segment is immutable"
end

function iSegment:__tostring()
  copy(lIn, self.name, szSegName)
  return string.format("[segment: l=%d t=%d r=%d b=%d mass=%d]", lIn.minX, lIn.minY, lIn.maxX, lIn.maxY, lIn.mass)
end

for fName, _ in pairs(snFields) do
  local mutatorName =
    'with' .. fName:sub(1,1):upper() .. fName:sub(2)
  Segment[mutatorName] = function(self, newVal)
    copy(out, self.name, szSegName)
    out[fName] = newVal
    return wrap(ffi_string(out, szSegName))
  end
end

return Segment
