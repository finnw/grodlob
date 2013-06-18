--proc/monitor: Multiple display monitors functions
setfenv(1, require'winapi')
require'winapi.window'

--creation

ffi.cdef [[

static const int CCHDEVICENAME = 32;

typedef struct tagMONITORINFOEXW
{
    DWORD   cbSize;
    RECT    rcMonitor;
    RECT    rcWork;
    DWORD   dwFlags;
    WCHAR   szDevice[CCHDEVICENAME];
} MONITORINFOEXW, MONITORINFOEX, *LPMONITORINFOEXW, *LPMONITORINFOEX;

BOOL GetMonitorInfoW(
  HMONITOR hMonitor,
  LPMONITORINFOEXW lpmi
);

HMONITOR MonitorFromWindow(
  HWND hwnd,
  DWORD flags
);

]]

MONITORINFOEX = struct {
  ctype='MONITORINFOEX',
  size='cbSize',
}

MONITOR_DEFAULTTONULL    = 0
MONITOR_DEFAULTTOPRIMARY = 1
MONITOR_DEFAULTTONEAREST = 2

function MonitorFromWindow(hwnd, f)
  return C.MonitorFromWindow(hwnd, flags(f))
end

function GetMonitorInfo(hMonitor, monitorInfo)
  monitorInfo = MONITORINFOEX(monitorInfo)
  checknz(C.GetMonitorInfoW(hMonitor, monitorInfo))
  return monitorInfo
end

