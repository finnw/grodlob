--proc/dialog: dialog box functions
setfenv(1, require'winapi')
require'winapi.window'

--creation

ffi.cdef [[

HWND CreateDialogParamW(
  HINSTANCE hInstance,
  LPCWSTR lpTemplate,
  HWND hWndParent,
  DLGPROC lpDialogFunc,
  LPARAM lparam
);

HWND GetDlgItem(
  HWND hDlg,
  int nIDDlgItem
);

LONG GetDialogBaseUnits();

]]

IDOK                 = 1
IDCANCEL             = 2
IDABORT              = 3
IDRETRY              = 4
IDIGNORE             = 5
IDYES                = 6
IDNO                 = 7
IDCLOSE              = 8
IDHELP               = 9
IDTRYAGAIN           = 10
IDCONTINUE           = 11
IDTIMEOUT            = 32000

function CreateDialog(hInstance, template, parent, dlgproc, lparam)
   local hwnd = checkh(C.CreateDialogParamW(
                        hInstance,
                        ffi.cast('LPCWSTR', wcs(MAKEINTRESOURCE(template))),
                        parent,
                        dlgproc,
                        lparam or 0))
   if not parent then own(hwnd, DestroyWindow) end
   return hwnd
end

function GetDlgItem(hDlg, nID)
  return C.GetDlgItem(checkh(hDlg), tonumber(nID))
end

function GetDialogBaseUnits()
   local long = C.GetDialogBaseUnits()
   return bit.band(long, 0xFFFF), bit.rshift(long, 16)
end

--commands
