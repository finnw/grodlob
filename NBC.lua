local mNBC = {}
local NBC = setmetatable({}, mNBC)
local iNBC = {__index=NBC}

function mNBC:__call(numClasses)
  self = {}
  local classPops = {}
  for i = 1, numClasses do
    classPops[i] = 1
  end
  self.classPops = classPops
  self.featurePops = {}
  self.featureStats = {}
  self.numClasses = numClasses
  self.totalPop = numClasses
  setmetatable(self, iNBC)
  return self
end

local emptyFW = {}
function NBC:classify(features, fw, priors)
  priors = priors or emptyFW
  fw = fw or emptyFW
  local weights = {}
  for cn, cp in ipairs(self.classPops) do
    table.insert(weights, math.log(priors[cn] or cp))
  end
  for _, ft in ipairs(features) do
    local fsEntry = self.featureStats[ft]
    if fsEntry then
      local fp = self.featurePops[ft]
      for i, cp in ipairs(self.classPops) do
        local smooth = .5 * cp / self.numClasses
        local with = fsEntry[i] + smooth
        local without = fp - fsEntry[i] + smooth
        local l = with / (with + without)
        weights[i] = weights[i] + math.log(l) * (fw[ft] or 1)
      end
    end
  end
  local wSum = 0
  for i, w in ipairs(weights) do
    w = math.exp(w)
    wSum = wSum + w
    weights[i] = w
  end
  for i, w in ipairs(weights) do
    weights[i] = w / wSum
  end
  return weights
end

function NBC:train1(features, class)
  self.classPops[class] = self.classPops[class] + 1
  self.totalPop = self.totalPop + 1
  for _, ft in ipairs(features) do
    local fsEntry = self.featureStats[ft]
    if not fsEntry then
      fsEntry = {}
      self.featureStats[ft] = fsEntry
      for i = 1, #self.classPops do
        fsEntry[i] = 0
      end
    end
    fsEntry[class] = fsEntry[class] + 1
    local fp = self.featurePops[ft] or 0
    self.featurePops[ft] = fp + 1
  end
end

return NBC