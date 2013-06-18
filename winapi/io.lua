--winapi.io: basic I/O functions
setfenv(1, require'winapi')

ffi.cdef[[

HANDLE CreateFileW(
  LPCWSTR lpFileName,
  DWORD dwDesiredAccess,
  DWORD dwShareMode,
  /*LPSECURITY_ATTRIBUTES*/ void *lpSecurityAttributes,
  DWORD dwCreationDisposition,
  DWORD dwFlagsAndAttributes,
  HANDLE hTemplateFile
);

BOOL CloseHandle(HANDLE handle);

]]

function CreateFile(fileName, desiredAccess, shareMode, securityAttributes, creationDisposition, flagsAndAttributes, hTemplateFile)
  local hFile =
  C.CreateFileW(wcs(fileName),
                flags(desiredAccess),
                flags(shareMode),
                securityAttributes,
                flags(creationDisposition),
                flags(flagsAndAttributes),
                hTemplateFile)
  return checkh(hFile)
end

function CloseHandle(handle)
  return checknz(C.CloseHandle(handle))
end

GENERIC_READ     = 0x80000000 
GENERIC_WRITE    = 0x40000000

FILE_SHARE_READ   = 0x00000001
FILE_SHARE_WRITE  = 0x00000002
FILE_SHARE_DELETE = 0x00000004

CREATE_NEW        = 1
CREATE_ALWAYS     = 2
OPEN_EXISTING     = 3
OPEN_ALWAYS       = 4
TRUNCATE_EXISTING = 5

FILE_FLAG_WRITE_THROUGH       = 0x80000000
FILE_FLAG_OVERLAPPED          = 0x40000000
FILE_FLAG_NO_BUFFERING        = 0x20000000
FILE_FLAG_RANDOM_ACCESS       = 0x10000000
FILE_FLAG_SEQUENTIAL_SCAN     = 0x08000000
FILE_FLAG_DELETE_ON_CLOSE     = 0x04000000
FILE_FLAG_BACKUP_SEMANTICS    = 0x02000000
FILE_FLAG_POSIX_SEMANTICS     = 0x01000000
FILE_FLAG_OPEN_REPARSE_POINT  = 0x00200000
FILE_FLAG_OPEN_NO_RECALL      = 0x00100000
FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000

FILE_ATTRIBUTE_READONLY            = 0x00000001  
FILE_ATTRIBUTE_HIDDEN              = 0x00000002  
FILE_ATTRIBUTE_SYSTEM              = 0x00000004  
FILE_ATTRIBUTE_DIRECTORY           = 0x00000010  
FILE_ATTRIBUTE_ARCHIVE             = 0x00000020  
FILE_ATTRIBUTE_DEVICE              = 0x00000040  
FILE_ATTRIBUTE_NORMAL              = 0x00000080  
FILE_ATTRIBUTE_TEMPORARY           = 0x00000100  
FILE_ATTRIBUTE_SPARSE_FILE         = 0x00000200  
FILE_ATTRIBUTE_REPARSE_POINT       = 0x00000400  
FILE_ATTRIBUTE_COMPRESSED          = 0x00000800  
FILE_ATTRIBUTE_OFFLINE             = 0x00001000  
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000  
FILE_ATTRIBUTE_ENCRYPTED           = 0x00004000  
FILE_ATTRIBUTE_VIRTUAL             = 0x00010000 