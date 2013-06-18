--proc/dialog: dialog box functions
setfenv(1, require'winapi')

ffi.cdef [[
  DWORD GetTickCount(void);
]]

function GetTickCount()
  return tonumber(C.GetTickCount())
end