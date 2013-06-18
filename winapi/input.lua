--proc/input: mouse & keyboard input functions
setfenv(1, require'winapi')
require'winapi.winuser'

local floor = math.floor

ffi.cdef [[

typedef struct tagMOUSEMOVEPOINT {
  int       x;
  int       y;
  DWORD     time;
  ULONG_PTR dwExtraInfo;
} MOUSEMOVEPOINT, *PMOUSEMOVEPOINT;

SHORT GetAsyncKeyState(
  int vKey
);

BOOL GetCursorPos(
  LPPOINT lpPoint
);

int GetMouseMovePointsEx(
  UINT cbSize,
  PMOUSEMOVEPOINT lppt,
  PMOUSEMOVEPOINT lpptBuf,
  int nBufPoints,
  DWORD resolution
);

]]

MOUSEMOVEPOINT = struct {
  ctype = 'MOUSEMOVEPOINT',
  fields = sfields{
		'x', 'x', pass, pass,
		'y', 'y', pass, pass,
		'time', 'time', pass, pass,
		'dwExtraInfo', 'dwExtraInfo', pass, pass,
  },
}

GMMP_USE_DISPLAY_POINTS = 1
GMMP_USE_HIGH_RESOLUTION_POINTS = 2

function GetAsyncKeyState(key)
  local w = C.GetAsyncKeyState(flags(key))
  return bit.band(w, 0x8000) ~= 0, bit.band(w, 1) ~= 0
end

function GetCursorPos(pt)
  pt = POINT(pt)
  checknz(C.GetCursorPos(pt))
  return pt.x, pt.y
end

do

local lastRawPoint, lastDisplayPoint, lastHiResPoint = '', '', ''
local outPts = ffi.new 'MOUSEMOVEPOINT[64]'
local szMouseMovePt = ffi.sizeof 'MOUSEMOVEPOINT'
local GMMP_USE_DISPLAY_POINTS = GMMP_USE_DISPLAY_POINTS
local GMMP_USE_HIGH_RESOLUTION_POINTS = GMMP_USE_HIGH_RESOLUTION_POINTS

local function wrapD(x)
  if x >= 0x8000 then x = x - 0x10000 end
  return x
end

function GetMouseMovePointsEx(startPt, limit, resolution, mmFix)
  startPt = MOUSEMOVEPOINT(startPt)
  local wrapHR
  if mmFix then
    startPt.x = bit.band(startPt.x, 0xffff)
    startPt.y = bit.band(startPt.y, 0xffff)
    local nVirtualWidth, nVirtualHeight, nVirtualLeft, nVirtualTop =
      GetSystemMetrics(SM_CXVIRTUALSCREEN),
      GetSystemMetrics(SM_CYVIRTUALSCREEN),
      GetSystemMetrics(SM_XVIRTUALSCREEN),
      GetSystemMetrics(SM_YVIRTUALSCREEN)
    local xOffset, yOffset = floor(0x1p32 / nVirtualWidth), floor(0x1p32 / nVirtualHeight)
    function wrapHR(x, y)
      if x >= 0x8p16 then x = x - xOffset end
      if y >= 0x8p16 then y = y - yOffset end
      local xOut = floor(((x * (nVirtualWidth - 1)) - (nVirtualLeft * 65536)) / nVirtualWidth)
      local yOut = floor(((y * (nVirtualHeight - 1)) - (nVirtualTop * 65536)) / nVirtualHeight)
      return xOut, yOut
    end
  end
  local maxPts = 64
  if tonumber(limit) then
    maxPts = math.max(0, math.min(tonumber(limit), 64))
  end
  local n = C.GetMouseMovePointsEx(szMouseMovePt, startPt, outPts, maxPts, flags(resolution))
  if n > 0 then
    local result = {}
    if mmFix and resolution == GMMP_USE_DISPLAY_POINTS then
      for i = 0, n - 1 do
        if limit == true then
          local pointKey = ffi.string(outPts[i], szMouseMovePt)
          if pointKey == lastDisplayPoint then break end
        end
        table.insert(result, {x=wrapD(outPts[i].x),
                              y=wrapD(outPts[i].y),
                              time=outPts[i].time})
      end
      lastDisplayPoint = ffi.string(outPts, szMouseMovePt)
    elseif mmFix and resolution == GMMP_USE_HIGH_RESOLUTION_POINTS then
      for i = 0, n - 1 do
        if limit == true then
          local pointKey = ffi.string(outPts[i], szMouseMovePt)
          if pointKey == lastHiResPoint then break end
        end
        local xOut, yOut = wrapHR(outPts[i].x, outPts[i].y)
        table.insert(result, {x=xOut, y=yOut, time=outPts[i].time})
      end
      lastHiResPoint = ffi.string(outPts, szMouseMovePt)
    else
      for i = 0, n - 1 do
        if limit == true then
          local pointKey = ffi.string(outPts[i], szMouseMovePt)
          if pointKey == lastRawPoint then break end
        end
        table.insert(result, {x=outPts[i].x,
                              y=outPts[i].y,
                              time=outPts[i].time})
      end
      lastRawPoint = ffi.string(outPts, szMouseMovePt)
    end
  --[[
     switch(mode)
   {
   case GMMP_USE_DISPLAY_POINTS:
      if (mp_out[i].x > 32767)
         mp_out[i].x -= 65536 ;
      if (mp_out[i].y > 32767)
         mp_out[i].y -= 65536 ;
      break ;
   case GMMP_USE_HIGH_RESOLUTION_POINTS:
      mp_out[i].x = ((mp_out[i].x * (nVirtualWidth - 1)) - (nVirtualLeft * 65536)) / nVirtualWidth ;
      mp_out[i].y = ((mp_out[i].y * (nVirtualHeight - 1)) - (nVirtualTop * 65536)) / nVirtualHeight ;
      break ;
   }
  ]]
  --[[
    for i = 0, n - 1 do
      
    end
    --]]
    return result
  end
end

end
