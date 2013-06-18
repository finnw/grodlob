--ownerdraw: Owner-draw control functions
setfenv(1, require'winapi')
require'winapi.window'
require'winapi.wingdi'

ffi.cdef [[

typedef struct tagDRAWITEMSTRUCT {
  UINT      CtlType;
  UINT      CtlID;
  UINT      itemID;
  UINT      itemAction;
  UINT      itemState;
  HWND      hwndItem;
  HDC       hDC;
  RECT      rcItem;
  ULONG_PTR itemData;
} DRAWITEMSTRUCT, *LPDRAWITEMSTRUCT;

]]