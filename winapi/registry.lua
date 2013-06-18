--proc/registry: registry API.
setfenv(1, require'winapi')

require 'winapi.wcs'
require 'winapi.winerror'

ffi.cdef[[
struct HKEY__ { int unused; }; typedef struct HKEY__ *HKEY;
typedef HKEY *PHKEY;

typedef LONG LSTATUS;

LSTATUS RegCloseKey (
  HKEY hKey
  );

LSTATUS RegCreateKeyW (
  HKEY hKey,
  LPCWSTR lpSubKey,
  PHKEY phkResult
  );

LSTATUS RegQueryValueExW (
  HKEY hKey,
  LPCWSTR lpValueName,
  LPDWORD lpReserved,
  LPDWORD lpType,
  LPBYTE lpData,
  LPDWORD lpcbData
  );

LONG RegSetValueExW(
  HKEY hKey,
  LPCWSTR lpValueName,
  DWORD Reserved,
  DWORD dwType,
  const BYTE *lpData,
  DWORD cbData
);

]]

REG_NONE                       = 0 
REG_SZ                         = 1 
REG_EXPAND_SZ                  = 2 
REG_BINARY                     = 3 
REG_DWORD                      = 4 
--REG_LINK                       = 6 
REG_MULTI_SZ                   = 7 
--REG_RESOURCE_LIST              = 8 
--REG_FULL_RESOURCE_DESCRIPTOR   = 9
--REG_RESOURCE_REQUIREMENTS_LIST = 10
REG_QWORD                      = 11

RRF_NOEXPAND = 0x10000000

local advapi32 = ffi.load 'advapi32'

local hkey = {}
hkey.__index = hkey

local autoClosedkeys = setmetatable({}, {__mode='k'})

local builtinKeys = {
  HKEY_CLASSES_ROOT        = 0x80000000,
  HKEY_CURRENT_USER        = 0x80000001,
  HKEY_LOCAL_MACHINE       = 0x80000002,
  HKEY_USERS               = 0x80000003,
  HKEY_PERFORMANCE_DATA    = 0x80000004,
  HKEY_CURRENT_CONFIG      = 0x80000005,
  HKEY_DYN_DATA            = 0x80000006,
  HKEY_PERFORMANCE_TEXT    = 0x80000050,
  HKEY_PERFORMANCE_NLSTEXT = 0x80000060,
}

local hkBuf = ffi.new 'HKEY[1]'

for mnemonic, keyId in pairs(builtinKeys) do
  local key = ffi.cast('HKEY', ffi.cast('uintptr_t', keyId))
  _M[mnemonic] = key
end

function RegCloseKey(hKey)
  checklstatus(advapi32.RegCloseKey(hKey))
end

function RegCreateKey(hKey, subKey)
  checklstatus(advapi32.RegCreateKeyW(hKey, wcs(subKey), hkBuf))
  return hkBuf[0]
end

do
  local dwType = ffi.new 'DWORD[1]'
  local cbData = ffi.new 'DWORD[1]'
  local bufSize = 0x100
  local ctBuffer = ffi.typeof 'uint8_t[?]'
  local buffer = ctBuffer(bufSize)
  local PWCS_ctype = ffi.typeof 'const WCHAR *'
  local PVOID_ctype = ffi.typeof 'const void *'
  local DWORD_ctype = ffi.typeof 'DWORD'
  local qwordBuf = ffi.new 'uint64_t[1]'

  function RegSetValue(hKey, valueName, data, valueType)
    if not valueType then
      if data == true then
        valueType = REG_NONE
      elseif type(data) == 'string' then
        valueType = REG_SZ
      elseif type(data) == 'cdata' then
        if ffi.istype('uint64_t', data) then
	  valueType = REG_QWORD
        elseif ffi.istype('uint32_t', data) then
	  valueType = REG_DWORD
        else
	  valueType = REG_BINARY
        end
      elseif type(data) == 'number' then
	valueType = REG_DWORD
      end
    else
      valueType = flags(valueType)
    end
    if not valueType then
      error("ambiguous type for registry value")
    end
    local cbData
    if type(data) == 'boolean' then
      data = nil
      cbData = 0
    elseif type(data) == 'string' then
      local sz
      data, sz = wcs_sz(data)
      cbData = (sz+1)*2
    elseif type(data) == 'number' then
      dwType[0] = data
      data = ffi.string(dwType, 4)
      cbData = 4
    else
      cbData = ffi.sizeof(data)
    end
    checkz(advapi32.RegSetValueExW(hKey, wcs(valueName), 0, valueType, ffi.cast(PVOID_ctype, data), cbData))
  end

  function RegGetValue(hKey, value)
    local wsValue = wcs(value)
    while true do
      cbData[0] = bufSize
      local status = advapi32.RegQueryValueExW(hKey, wsValue, nil, dwType, buffer, cbData)
      if status == 0 then
        if dwType[0] == REG_SZ or dwType[0] == REG_EXPAND_SZ then
          local ws = ffi.cast(PWCS_ctype, buffer)
          return mbs(ws), tonumber(dwType[0])
        elseif dwType == REG_NONE or dwType[0] == REG_BINARY then
          local bytes = ctBuffer(cbData[0])
          ffi.copy(bytes, buffer, cbData[0])
          return bytes, tonumber(dwType[0])
        elseif dwType == REG_DWORD then
          local result = 0
          for i = 3, 0, -1 do
            result = bit.bor(bit.lshift(result, 8), buffer[i])
          end
          return tonumber(ffi.cast(DWORD_ctype, result)), tonumber(dwType[0])
        elseif dwType == REG_QWORD then
          ffi.copy(qwordBuf, buffer, 8)
          return qwordBuf[0]
        else
          error("unsupported registry value type: " .. tonumber(dwType[0]))
        end
      elseif status == ERROR_MORE_DATA or status == ERROR_INSUFFICIENT_BUFFER then
        bufSize = bufSize * 2
	buffer = ctBuffer(bufSize)
      elseif status == ERROR_FILE_NOT_FOUND then
        return nil
      else
        checklstatus(status)
        return nil
      end
    end
  end
end

hkey.Close = RegCloseKey
hkey.Create = RegCreateKey
hkey.GetValue = RegGetValue
hkey.SetValue = RegSetValue

ffi.metatype('struct HKEY__', hkey)

