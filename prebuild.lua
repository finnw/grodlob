local lj_src_dir = "..\\luajit-2.0\\src"
local luajit = string.format("%s\\luajit.exe", lj_src_dir)
local precompile_modules = {
  {name="Watershed"},
  {name="ffilib"},
  {name="ffiu"},
  {name="lept.FPix", input="lept\\FPix.lua", output="FPix.c"},
  {name="lept.NumA", input="lept\\NumA.lua", output="NumA.c"},
  {name="lept.Pix", input="lept\\Pix.lua", output="Pix.c"},
  {name="lept.PixA", input="lept\\PixA.lua", output="PixA.c"},
  {name="lept.Pta", input="lept\\Pta.lua", output="Pta.c"},
  {name="liblept"},
  {name="pixelsort_cdef"},
  {name="point16"},
}

local luaPath = string.format("%s\\?.lua", lj_src_dir)
local commands = {
  string.format("set LUA_PATH=%s", luaPath)
}
for _, m in ipairs(precompile_modules) do
  local aPath = m.name:gsub("%.", "\\")
  local inputFile = m.input or aPath .. ".lua"
  local outputFile = m.output or aPath .. ".c"
  local command = string.format("%q -bg -n %q %q %q", luajit, m.name, inputFile, outputFile)
  table.insert(commands, command)
end
table.insert(commands, "")
local batchFD = io.open("temp.bat", 'w')
local batch = table.concat(commands, "\n"):gsub("\\\\", "\\")
batchFD:write(batch)
batchFD:close()
os.execute "temp.bat"
