local ffi = require 'ffi'
local ffiu = require 'ffiu'
local liblept = require 'liblept'

local mNumA = {}
local NumA = setmetatable({}, mNumA)
local iNumA = {__index = mNumA}

local ctPNumA = ffi.typeof 'NUMA *'

local NumAHost = {}
local iNumAHost = {__index=NumAHost}
local ctNumAHost, szNumAHost

local clLept = getmetatable(liblept).__index

local nonNull = ffiu.nonNull

local wrapperMap = setmetatable({}, {__mode='v'})
local function wrap(pnuma)
  if not (pnuma and nonNull(pnuma)) then return nil end
  assert(ffi.istype(pnuma, ctPNumA), 'argument must be a NUMA*')
  local host = ctNumAHost()
  host.handles[0] = pnuma
  local key = ffi.string(host, szNumAHost)
  local self = wrapperMap[key]
  if not self then 
    self = {host = host}
    setmetatable(self, iNumA)
    wrapperMap[key] = self
  end
  return self
end
NumA.wrap = wrap

local function toPNumA(numa)
  if numa == nil then
    return nil
  elseif ffi.istype(ctNumAHost, numa) then
    return nonNull(numa.handles[0])
  elseif type(numa) == 'table' and getmetatable(numa) == iNumA then
    return toPNumA(numa.host)
  else
    error("Invalid NumA designator: " .. tostring(numa), 3)
  end
end

function NumA:getCount()
  return clLept.numaGetCount(toPNumA(self))
end

function iNumA:__len()
  return self:getCount()
end

function iNumAHost:__gc()
  assert(nonNull(self.handles[0]))
  clLept.numaDestroy(self.handles)
end

ctNumAHost = ffi.metatype('struct {NUMA *handles[1];}', iNumAHost)
szNumAHost = ffi.sizeof(ctNumAHost)

return NumA