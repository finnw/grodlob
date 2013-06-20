local mUnionFind = {}
local UnionFind = setmetatable({}, mUnionFind)
local iUnionFind = {__index=UnionFind}

function mUnionFind:__call(val)
  self = {rank=0, val=val}
  self.parent = self
  return setmetatable(self, iUnionFind)
end

function UnionFind:add(val)
  self = self:find()
  self.val = self.val + val
end

function UnionFind:find()
  local last = self
  local valAccum = nil
  while not rawequal(self, self.parent) do
    last.parent = self.parent
    assert(not rawequal(self.parent, last))
    if last.val then
      if valAccum == nil then
        valAccum = last.val
      else
        valAccum = valAccum + last.val
      end
      last.val = nil
    end
    last = self
    self = self.parent
  end
  assert(self.val)
  if valAccum ~= nil then
    self.val = self.val + valAccum
  end
  return self
end

function UnionFind:merge(other)
  local root1, root2 = other:find(), self:find()
  if rawequal(root1, root2) then
    return root1
  elseif root1.rank < root2.rank then
    root1.parent = root2
    assert(not rawequal(root1, root2))
    assert(root1.val and root2.val)
    root2.val = root1.val + root2.val
    root1.val = nil
    return root2
  elseif root1.rank > root2.rank then
    root2.parent = root1
    assert(not rawequal(root1, root2))
    assert(root1.val and root2.val)
    root1.val = root1.val + root2.val
    root2.val = nil
    return root1
  else
    root2.parent = root1
    assert(not rawequal(root1, root2))
    assert(root1.val and root2.val)
    root1.val = root1.val + root2.val
    root2.val = nil
    root1.rank = root1.rank + 1
    return root1
  end
end

function iUnionFind.__eq(x, y)
  return rawequal(x:find(), y:find())
end

function iUnionFind:__tostring()
  if rawequal(self.parent, self) then
    return '<root UnionFind with val=' .. tostring(self.val) .. '>'
  else
    return '<non-root UnionFind>'
  end
end

return UnionFind
