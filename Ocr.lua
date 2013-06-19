local ffi = require 'ffi'
local libyflood = require 'libyflood'
local sqlsearcher = require 'sqlsearcher'

local mOcr = {}
local Ocr = setmetatable({}, mOcr)
local iOcr = {__index=Ocr}

ffi.cdef [[

struct ocr_holder
{
    HOCR handles[1];
};

]]
local ctOcr

local getfile = sqlsearcher.getfile

function mOcr:__call()
  local holder = ffi.new(ctOcr)
  local allocResult = libyflood.yf_ocr_new(nil, holder.handles)
  if allocResult ~= 0 then
    local msg = 'OCR subsystem init failed: code ' .. math.abs(allocResult)
    error(msg)
  else
    return holder
  end
end

function Ocr:read(bitmap)
  local guesses = ffi.new('struct char_guess[3]')
  local guessTab = {}
  libyflood.yf_ocr_read(self.handles[0],
                        bitmap.topLeft,
                        bitmap.width, bitmap.height,
                        bitmap.xStride, bitmap.yStride,
                        guesses, 3)
  for i = 0, 2 do
    if guesses[i].codePoint == 0 or guesses[i].prob ~= guesses[i].prob then
      break
    else
      local c = string.char(guesses[i].codePoint)
      guessTab[c] = guesses[i].prob
    end
  end
  return guessTab
end

function iOcr:__gc()
  libyflood.yf_ocr_free(self.handles[0])
end

ctOcr = ffi.metatype('struct ocr_holder', iOcr)

return Ocr
