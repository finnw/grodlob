--: winerror: Windows error functions & constants
package.loaded[...] = true
setfenv(1, require'winapi')

ERROR_SUCCESS = 0
ERROR_FILE_NOT_FOUND = 2
ERROR_PATH_NOT_FOUND = 3
ERROR_INSUFFICIENT_BUFFER = 122
ERROR_MORE_DATA = 234

