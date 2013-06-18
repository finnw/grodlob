--winapi.thread: thread functions
setfenv(1, require'winapi')

ffi.cdef[[

HANDLE GetCurrentThread(void);

BOOL SetThreadPriority(
  HANDLE hThread,
  int nPriority
);

void Sleep(DWORD dwMilliseconds);

]]

THREAD_PRIORITY_BELOW_NORMAL = -1
THREAD_PRIORITY_NORMAL = 0
THREAD_PRIORITY_ABOVE_NORMAL = 1
THREAD_PRIORITY_HIGHEST = 2
THREAD_PRIORITY_TIME_CRITICAL = 15

function SetThreadPriority(hThread, priority)
  checknz(C.SetThreadPriority(hThread, priority))
end

GetCurrentThread = C.GetCurrentThread

Sleep = C.Sleep

ffi.cdef[[

LONG __cdecl InterlockedCompareExchange(
  LONG volatile *Destination,
  LONG Exchange,
  LONG Comparand
);

LONG __cdecl InterlockedDecrement(
  LONG volatile *Addend
);

LONG __cdecl InterlockedExchange(
  LONG volatile *Target,
  LONG Value
);

LONG __cdecl InterlockedExchangeAdd(
  LONG volatile *Addend,
  LONG Value
);

LONG __cdecl InterlockedIncrement(
  LONG volatile *Addend
);

]]

InterlockedCompareExchange = C.InterlockedCompareExchange
InterlockedDecrement = C.InterlockedDecrement
InterlockedExchange = C.InterlockedExchange
InterlockedExchangeAdd = C.InterlockedExchangeAdd
InterlockedIncrement = C.InterlockedIncrement