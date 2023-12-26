#!/usr/bin/make -f

# Name of ROM file
title = ff-snes

# Location of files
bindir = bin
objdir = obj
srcdir = prg
imgdir = chr

# List of files to build
objlist = vectors

AS65 = ca65 -g
LD65 = ld65 --dbgfile $(bindir)/$(title).dbg -m $(bindir)/map.txt

.PHONY: clean

all: $(bindir)/ $(objdir)/ $(bindir)/$(title).smc

clean:
	-rm $(objdir)/*.o $(bindir)/$(title).smc $(bindir)/$(title).dbg $(bindir)/map.txt

$(bindir)/: Makefile
	mkdir -p $(bindir)

$(objdir)/: Makefile
	mkdir -p $(objdir)

objlisto = $(foreach o,$(objlist),$(objdir)/$(o).o)

$(bindir)/map.txt $(bindir)/$(title).smc: lorom.cfg $(objlisto)
	$(LD65) -o $(bindir)/$(title).smc -C $^

$(objdir)/%.o: $(srcdir)/%.asm
	$(AS65) $< -o $@
