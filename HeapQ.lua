local mHeapQ = {}
local HeapQ = setmetatable({}, mHeapQ)
local iHeapQ = {__index=HeapQ}

local function fwd(a, b) return a < b end
local function rev(a, b) return a > b end

function mHeapQ:__call(cmp)
  self = {}
  if cmp == true then
    self.cmp = rev
  elseif not cmp then
    self.cmp = fwd
  else
    self.cmp = cmp
  end
  self.heap = {}
  self.nodes = {}
  self.n = 0
  return setmetatable(self, iHeapQ)
end

function HeapQ:add(k, v)
  assert(type(k) == 'table')
  assert(type(v) == 'number')
  assert(v ~= nil, "cannot push nil")
  local t = self.nodes
  local h = self.heap
  local cmp = self.cmp
  local n = self.n + 1 -- node position in heap array (leaf)
  local p = (n - n % 2) / 2 -- parent position in heap array
  h[n] = k -- insert at a leaf
  t[n] = v
  self.n = n
  while n > 1 and cmp(v, t[p]) do -- climb heap?
    h[p], h[n] = h[n], h[p]
    n = p
    p = (n - n % 2) / 2
  end
end

function HeapQ:peek()
  local t = self.nodes
  local h = self.heap
  local s = self.n
  assert(s > 0, "cannot peek into empty heap")
  local e = h[1] -- min (heap root)
  local r = t[1]
  return e, r
end

function HeapQ:pop()
  local t = self.nodes
  local h = self.heap
  local s = self.n
  local cmp = self.cmp
  assert(s > 0, "cannot pop from empty heap")
  local e = h[1] -- min (heap root)
  local r = t[1]
  local v = t[s]
  h[1] = h[s] -- move leaf to root
  t[1] = t[s]
  h[s] = nil -- remove leaf
  t[s] = nil
  s = s - 1
  local n = 1 -- node position in heap array
  local p = 2 * n -- left sibling position
  if s > p and cmp(t[p+1], t[p]) then
    p = 2 * n + 1 -- right sibling position
  end
  while s >= p and cmp(t[p], v) do -- descend heap?
    h[p], h[n] = h[n], h[p]
    t[p], t[n] = t[n], t[p]
    n = p
    p = 2 * n
    if s > p and cmp(t[p+1], t[p]) then
      p = 2 * n + 1
    end
  end
  self.n = s
  return e, r
end

function HeapQ:isEmpty()
  return self.n <= 0
end

function HeapQ:size()
  return self.n
end

function iHeapQ:__len()
  return self.n
end

return HeapQ