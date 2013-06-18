--winapi.mmap: file mapping functions
setfenv(1, require'winapi')

ffi.cdef[[

HANDLE CreateFileMappingW(
  HANDLE hFile,
  void *lpAttributes,
  DWORD flProtect,
  DWORD dwMaximumSizeHigh,
  DWORD dwMaximumSizeLow,
  LPCWSTR lpName
);

HANDLE OpenFileMappingW(
  DWORD dwDesiredAccess,
  BOOL bInheritHandle,
  LPCWSTR lpName
);

LPVOID MapViewOfFile(
  HANDLE hFileMappingObject,
  DWORD dwDesiredAccess,
  DWORD dwFileOffsetHigh,
  DWORD dwFileOffsetLow,
  DWORD dwNumberOfBytesToMap
);

BOOL UnmapViewOfFile(
  LPCVOID lpBaseAddress
);

]]

PAGE_EXECUTE_READ = 0x20
PAGE_EXECUTE_READWRITE = 0x40
PAGE_EXECUTE_WRITECOPY = 0x80
PAGE_READONLY = 2
PAGE_READWRITE = 4
PAGE_WRITECOPY = 8
SEC_COMMIT = 0x8p24
SEC_IMAGE = 0x1p24
SEC_IMAGE_NO_EXECUTE = 0x11p24
SEC_LARGE_PAGES = 0x8p28
SEC_NOCACHE = 0x1p28
SEC_RESERVE = 0x4p24
SEC_WRITECOMBINE = 0x4p28
FILE_MAP_COPY = 1
FILE_MAP_WRITE = 2
FILE_MAP_READ = 4
FILE_MAP_EXECUTE = 0x20
FILE_MAP_ALL_ACCESS = 0xf001f

local ctDouble = ffi.typeof 'double'
local ctUInt32 = ffi.typeof 'uint32_t'
local ctUInt64 = ffi.typeof 'uint64_t'
local ctHandle = ffi.typeof 'HANDLE'

function CreateFileMapping(hFile, attributes, protect, maximumSize, name)
  if hFile == nil then
    hFile = ffi.cast(ctHandle, -1)
  end
  local maximumSizeLow = ffi.cast(ctUInt32, maximumSize)
  local maximumSizeHigh = math.floor(0x1p-32 * tonumber(ffi.cast(ctDouble, maximumSize)))
  return checkh(C.CreateFileMappingW(hFile, attributes, flags(protect), maximumSizeHigh, maximumSizeLow, wcs(name)))
end

function OpenFileMapping(desiredAccess, inheritHandle, name)
  local h = C.OpenFileMappingW(flags(desiredAccess), inheritHandle, wcs(name))
  if h == nil then
    return nil -- replace null pointer with "real" nil
  else
    return h
  end
end

function MapViewOfFile(hFileMappingObject, desiredAccess, fileOffset, numberOfBytesToMap)
  local fileOffsetLow = ffi.cast(ctUInt32, fileOffset)
  local fileOffsetHigh = math.floor(0x1p-32 * tonumber(ffi.cast(ctDouble, fileOffset)))
  return checkh(C.MapViewOfFile(hFileMappingObject, flags(desiredAccess), fileOffsetHigh, fileOffsetLow, numberOfBytesToMap))
end

function UnmapViewOfFile(baseAddress)
  checknz(C.UnmapViewOfFile(baseAddress))
end
