#include "lua.h"
#include "lauxlib.h"

extern const char luaJIT_BC_Watershed[];
extern const char luaJIT_BC_ffiu[];
extern const char luaJIT_BC_lept_FPix[];
extern const char luaJIT_BC_lept_NumA[];
extern const char luaJIT_BC_lept_Pix[];
extern const char luaJIT_BC_lept_PixA[];
extern const char luaJIT_BC_lept_Pta[];
extern const char luaJIT_BC_liblept[];
extern const char luaJIT_BC_point16[];

struct bc_preload
{
	const char *name;
	const char *bc;
} bc_preloads[] =
{
	{"Watershed", luaJIT_BC_Watershed},
	{"ffiu", luaJIT_BC_ffiu},
	{"lept.FPix", luaJIT_BC_lept_FPix},
	{"lept.NumA", luaJIT_BC_lept_NumA},
	{"lept.Pix", luaJIT_BC_lept_Pix},
	{"lept.PixA", luaJIT_BC_lept_PixA},
	{"lept.Pta", luaJIT_BC_lept_Pta},
	{"liblept", luaJIT_BC_lept_Pta},
	{"point16", luaJIT_BC_point16},
	{NULL, NULL}
};

int __declspec(dllexport) luaopen_grodlob(lua_State *L)
{
	struct bc_preload *ppreload;

	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	lua_remove(L, -2);
	for (ppreload = bc_preloads; ppreload->name; ++ ppreload)
	{
		luaL_loadbuffer(L, ppreload->bc, (size_t)-1, ppreload->name);
		lua_setfield(L, -2, ppreload->name);
	}

	lua_settop(L, 0);
	lua_pushboolean(L, 1);
	return 1;
}