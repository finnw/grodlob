local ffi = require 'ffi'
local ffiu = require 'ffiu'
local liblept = require 'liblept'

local mPixA = {}
local PixA = setmetatable({}, mPixA)
local iPixA = {__index = mPixA}

local ctPPixA = ffi.typeof 'PIXA *'

local PixAHost = {}
local iPixAHost = {__index=PixAHost}
local ctPixAHost, szPixAHost

local clLept = getmetatable(liblept).__index

local nonNull = ffiu.nonNull

local wrapperMap = setmetatable({}, {__mode='v'})
local function wrap(ppixa)
  if not (ppixa and nonNull(ppixa)) then return nil end
  assert(ffi.istype(ppixa, ctPPixA), 'argument must be a PIXA*')
  local host = ctPixAHost()
  host.handles[0] = ppixa
  local key = ffi.string(host, szPixAHost)
  local self = wrapperMap[key]
  if not self then 
    self = {host = host}
    setmetatable(self, iPixA)
    wrapperMap[key] = self
  end
  return self
end
PixA.wrap = wrap

local function toPPixA(numa)
  if numa == nil then
    return nil
  elseif ffi.istype(ctPixAHost, numa) then
    return nonNull(pixa.handles[0])
  elseif type(pixa) == 'table' and getmetatable(pixa) == iPixA then
    return toPPixA(pixa.host)
  else
    error("Invalid PixA designator: " .. tostring(pixa), 3)
  end
end

function PixA:getCount()
  return clLept.pixaGetCount(toPPixA(self))
end

function iPixA:__len()
  return self:getCount()
end

function iPixAHost:__gc()
  clLept.pixaDestroy(self.handles)
end

ctPixAHost = ffi.metatype('struct {PIXA *handles[1];}', iPixAHost)

return PixA