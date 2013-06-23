CC=gcc-mp-4.7
#CCC=g++-mp-4.7
CFLAGS=-Iluajit-2.0/src -Iinclude
LIBS=-llept -lluajit
LUAJIT=luajit-2.0/src/luajit
LUAB=LUA_PATH="./?.lua;luajit-2.0/src/?.lua" $(LUAJIT) -bg
LDFLAGS=-Lluajit-2.0/src -L/opt/local/lib
SRCS=pixelsort.c
COBJS=$(SRCS:.c=.o)
LUABCS=FPix.c NumA.c Pta.c Pix.c PixA.c Watershed.c ffiu.c liblept.c pixelsort_cdef.c point16.c
LUAOBJS=$(LUABCS:.c=.o)

default: libgrodlob.so

# Grodlob C modules
pixelsort.o: pixelsort.c
	$(CC) $(CFLAGS) -o $@ -c $<

.o: .c
	$(CC) $(CFLAGS) -c $<

FPix.c: lept/FPix.lua
	$(LUAB) -n lept.FPix $< $@
NumA.c: lept/NumA.lua
	$(LUAB) -n lept.NumA $< $@
Pix.c: lept/Pix.lua
	$(LUAB) -n lept.Pix $< $@
PixA.c: lept/PixA.lua
	$(LUAB) -n lept.PixA $< $@
Pta.c: lept/Pta.lua
	$(LUAB) -n lept.Pta $< $@
Watershed.c: Watershed.lua
	$(LUAB) $< $@
ffiu.c: ffiu.lua
	$(LUAB) $< $@
liblept.c: liblept.lua
	$(LUAB) $< $@
pixelsort_cdef.c: pixelsort_cdef.lua
	$(LUAB) $< $@
point16.c: point16.lua
	$(LUAB) $< $@

# Main DLL
libgrodlob.so: $(COBJS) $(LUAOBJS)
	$(CC) $(LDFLAGS) -dynamiclib -o $@ $(COBJS) $(LUAOBJS) $(LIBS)

clean:
	rm -f $(COBJS) $(LUABCS) $(LUAOBJS) OCRService
#vim: noexpandtab softtabstop=0
