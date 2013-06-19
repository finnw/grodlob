local ffi = require 'ffi'
local ffiu = require 'ffiu'
local liblept = require 'liblept'
local prof -- Optional module
do
  local profOk
  profOk, prof = pcall(require, 'prof')
end
local NumA = require 'lept.NumA'
local PixA = require 'lept.PixA'
local Pta = require 'lept.Pta'
local W
do
  local WOk
  WOk, theW = pcall(require, 'winapi')
  if WOk then
    W = theW
    require 'winapi.window'
    require 'winapi.wingdi'
  end
end

local mPix = {}
local Pix = setmetatable({}, mPix)
local iPix = {__index=Pix}

local ctPPix = ffi.typeof 'struct Pix *'

local PixHost = {}
local iPixHost = {__index=PixHost}
local ctPixHost, szPizHost

local DibHost = {}
local iDibHost = {__index=DibHost}
local ctDibHost, szDibHost

local clLept = getmetatable(liblept).__index

local nonNull = ffiu.nonNull
local toPPix

local getMemUsage
do
  local wBuf, hBuf, dBuf = ffi.new 'l_int32[1]', ffi.new 'l_int32[1]', ffi.new 'l_int32[1]'
  function Pix:getDimensions()
    local ppix = toPPix(self)
    assert(ppix ~= nil)
    assert(clLept.pixGetDimensions(ppix, wBuf, hBuf, dBuf) == 0, "error getting dimensions")
    return wBuf[0], hBuf[0], dBuf[0]
  end

  function getMemUsage(ppix)
    if ppix == nil or clLept.pixGetData(ppix) == nil then return 0 end
    assert(clLept.pixGetDimensions(ppix, wBuf, hBuf, dBuf) == 0, "error getting dimensions")
    local bpl = wBuf[0] * dBuf[0]
    local wpl = bit.arshift(bit.bor(bpl - 1, 31) + 1, 5)
    local result = hBuf[0] * wpl * 4
    assert(result > 0)
    return result
  end
end

local weakValues = {__mode='v'}
local pixWrappers = setmetatable({}, weakValues)
local dibWrappers = setmetatable({}, weakValues)
local function wrap(ppix)
  if not (ppix and nonNull(ppix)) then return nil end
  assert(ffi.istype(ppix, ctPPix), 'argument must be a Pix*')
  local host = ctPixHost()
  host.handles[0] = ppix
  local key = ffi.string(host, szPixHost)
  local self = pixWrappers[key]
  if not self then
    assert(dibWrappers[key] == nil) -- Must not wrap these - it causes double-frees
    self = {host = host}
    setmetatable(self, iPix)
    pixWrappers[key] = self
    if prof then prof.update('pixMemUsed', getMemUsage(ppix)) end
  end
  return self
end
Pix.wrap = wrap

function toPPix(pix)
  if pix == nil then
    return nil
  elseif ffi.istype(ctPixHost, pix) or (W and ffi.istype(ctDibHost, pix)) then
    return nonNull(pix.handles[0])
  elseif type(pix) == 'table' and getmetatable(pix) == iPix then
    return toPPix(pix.host)
  else
    error("Invalid Pix designator: " .. tostring(pix), 3)
  end
end

function Pix.convertRGBToHSV(pixd, pixs)
  local ppixs = toPPix(pixs)
  assert(nonNull(ppixs))
  return wrap(clLept.pixConvertRGBToHSV(toPPix(pixd), ppixs))
end

function Pix.create(width, height, depth)
  local ppix = clLept.pixCreate(width, height, depth)
  assert(nonNull(ppix))
  return wrap(ppix)
end

if W then
  local bmi = ffi.new('BITMAPINFO', 4)
  do
    local bmiWords = ffi.cast('uint32_t *', bmi.bmiColors)
    bmiWords[0] = 0xff000000
    bmiWords[1] = 0x00ff0000
    bmiWords[2] = 0x0000ff00
    bmiWords[3] = 0x00000000
  end
  function Pix.createDIBSection(hdc, width, height)
    local h = bmi.bmiHeader
    h.biSize = ffi.sizeof(h)
    h.biWidth = width
    h.biHeight = - height
    h.biPlanes = 1
    h.biBitCount = 32
    h.biCompression = W.BI_BITFIELDS
    h.biSizeImage = width * math.abs(height) * 4
    local hbmp, bits = W.CreateDIBSection(hdc, bmi, DIB_RGB_COLORS)
    local pPix = clLept.pixCreateHeader(width, height, 32)
    clLept.pixChangeRefcount(pPix, 1)
    clLept.pixSetData(pPix, bits)
    local self = {host = ctDibHost()}
    self.host.handles[0] = pPix
    if prof then prof.update('dibMemUsed', getMemUsage(pPix)) end
    self.host.hbmp = hbmp;
    setmetatable(self, iPix)
    local key = ffi.string(self.host.handles, szPixHost) -- Only the Pix pointer is significant, not the HBITMAP
    dibWrappers[key] = self
    return self
  end
  ctDibHost = ffi.metatype('struct {struct Pix *handles[1]; HBITMAP hbmp;}', iDibHost)
end

do
  local function initCIFlags(t)
    local added = {}
    for k, v in pairs(t) do
      if type(k) == 'string' then
        added[string.lower(k)] = v
        added[string.upper(k)] = v
      end
    end
    for k, v in pairs(added) do
      t[k] = v
    end
  end
  local typeCodes = {
    L_HS_HISTO = liblept.L_HS_HISTO,
    HS_HISTO = liblept.L_HS_HISTO,
    HS = liblept.L_HS_HISTO,
  }
  local ppta = ffi.new 'PTA *[1]'
  local pnatot = ffi.new 'NUMA *[1]'
  local ppixa = ffi.new 'PIXA *[1]'
  initCIFlags(typeCodes)
  local none = {}
  function Pix.findHistoPeaksHSV(pixs, type, width, height, npeaks, erasefactor, wantPixA)
    ppixa[0] = nil
    local status = clLept.pixFindHistoPeaksHSV(toPPix(pixs), typeCodes[type or none] or type, width, height, npeaks, erasefactor, ppta, pnatot, wantPixA and ppixa or nil)
    assert(status == 0, "pixFindHistoPeaksHSV failed")
    return Pta.wrap(ppta[0]), NumA.wrap(pnatot[0]), PixA.wrap(ppixa[0])
  end
end

function Pix:getData()
  return clLept.pixGetData(toPPix(self))
end

do
  local fractDiff = ffi.new 'float[1]'
  local aveDiff = ffi.new 'float[1]'
  local similar = ffi.new 'l_int32[1]'
  function Pix.getDifferenceStats(pix1, pix2, factor, mindiff, printstats)
    if printstats == nil then printstats = false end
    local status = clLept.pixGetDifferenceStats(toPPix(pix1), toPPix(pix2), factor or 0, mindiff or 1, fractDiff, aveDiff, printstats)
    assert(status == 0, "pixGetDifferenceStats failed")
    return fractDiff[0], aveDiff[0]  
  end

  function Pix.testForSimilarity(pix1, pix2, factor, mindiff, maxfract, maxave, printstats)
    if printstats == nil then printstats = false end
    local status = clLept.pixTestForSimilarity(toPPix(pix1), toPPix(pix2), factor or 0, mindiff or 1, maxfract or 0, maxave or 0, similar, printstats)
    assert(status == 0, "pixTestForSimilarity failed")
    return similar[0] ~= 0  
  end
end

do
  local prval = ffi.new 'int32_t[1]'
  local pgval = ffi.new 'int32_t[1]'
  local pbval = ffi.new 'int32_t[1]'
  function Pix:getRGBPixel(x, y)
    local status = clLept.pixGetRGBPixel(toPPix(self), x, y, prval, pgval, pbval)
    if status ~= 0 then
      local msg = string.format("failed to read pixel at [%s,%s]", tostring(x), tostring(y))
      error(msg)
    end
    return prval[0], pgval[0], pbval[0]
  end
end

function Pix:getWpl()
  return clLept.pixGetWpl(toPPix(self))
end

do
  local none = {}
  local pnahue = ffi.new 'NUMA *[1]'
  local pnasat = ffi.new 'NUMA *[1]'
  function Pix.makeHistoHS(pixs, factor, opt)
    opt = opt or none
    local result = clLept.pixMakeHistoHS(toPPix(pixs), factor or 0, opt.hue and pnahue or nil, opt.sat and pnasat or nil)
    result = nonNull(result)
    assert(result, "pixMakeHistoHS failed")
    if opt.hue then
      opt.hue = NumA.wrap(pnahue[0])
      pnahue[0] = nil
    else
      clLept.numaDestroy(pnahue)
    end
    if opt.sat then
      opt.sat = NumA.wrap(pnasat[0])
      pnasat[0] = nil
    else
      clLept.numaDestroy(pnahue)
    end
    return wrap(result)
  end
end

function Pix:rasterop(dx, dy, dw, dh, op, src, sx, sy)
  return clLept.pixRasterop(toPPix(self), dx, dy, dw, dh, op, toPPix(src), sx or 0, sy or 0)
end

function Pix.read(src, hint)
  local ppix
  if type(src) == 'string' then
    if hint then
      ppix = clLept.pixReadWithHint(src, tonumber(hint))
    else
      ppix = clLept.pixRead(src)
    end
  elseif io.type(src) then
    ppix = clLept.pixReadStream(src, tonumber(hint or 0))
  else
    error("Invalid image source: " .. tostring(src))
  end
  return wrap(ppix)
end

function Pix.rotate(pixs, angle, type, incolor, width, height)
  return Pix(clLept.pixRotate(toPPix(pixs), angle, type, incolor, width or 0, height or 0))
end

function Pix:writePng(filename, gamma)
  return clLept.pixWritePng(filename, self.host.handles[0], gamma or 0) == 0
end

local function showPix(p)
  if p == nil then return "<Pix @ NULL>" end
  local text = (p.text ~= nil) and string.format("%q", p.text) or "nil"
  return string.format("<Pix @ %p: w=%u; h=%u; d=%u; wpl=%u; refcount=%u; xres=%d; yres=%d; informat=%d; text=%s; colormap=%s; data=%s>",
                       p, p.w, p.h, p.d, p.wpl, p.refcount, p.xres, p.yres, p.informat, text, tostring(p.colormap), tostring(p.data))
end

function iPixHost:__gc()
  if prof then prof.update('pixMemUsed', -getMemUsage(self.handles[0])) end
  clLept.pixDestroy(self.handles)
end

function iDibHost:__gc()
  local ppix = self.handles[0]
  clLept.pixChangeRefcount(ppix, -1)
  local newRefcount = clLept.pixGetRefcount(ppix)
  if newRefcount == 1 then
    if prof then prof.update('dibMemUsed', -getMemUsage(ppix)) end
    clLept.pixSetData(ppix, nil)
    W.DeleteObject(self.hbmp)
    clLept.pixDestroy(self.handles)
  end  
end

local accessors = {}
PixHost.index = {}
DibHost.index = {}

function PixHost.index:isDIBSection()
  return false
end

function DibHost.index:isDIBSection()
  return nonNull(self.host.hbmp)
end

function accessors:w()
  return select(1, self:getDimensions())
end

function accessors:h()
  return select(2, self:getDimensions())
end

function iPix:__index(k)
  local acc = accessors[k]
  if acc then
    return acc(self)
  else
    return Pix[k] or self.host.index[k]
  end
end

function iPix:__tostring()
  local p = toPPix(self)
  return showPix(p)
end

ctPixHost = ffi.metatype('struct {struct Pix *handles[1];}', iPixHost)
szPixHost = ffi.sizeof(ctPixHost)

setmetatable(Pix, mPix)

return Pix
