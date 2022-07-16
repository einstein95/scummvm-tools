#######################################################################
# Default compilation parameters. Normally don't edit these           #
#######################################################################

srcdir      ?= .

DEFINES     := -DHAVE_CONFIG_H
LDFLAGS     :=
INCLUDES    := -I. -I$(srcdir)
LIBS        :=
OBJS        :=
DEPDIR      := .deps

MODULES     :=
MODULE_DIRS :=

STANDALONE  :=
# This one will go away once all tools are converted
NO_MAIN     := -DEXPORT_MAIN


# Load the make rules generated by configure
-include config.mk

ifeq "$(HAVE_GCC)" "1"
	CXXFLAGS:= -Wall $(CXXFLAGS)
	# Turn off some annoying and not-so-useful warnings
	CXXFLAGS+= -Wno-long-long -Wno-multichar -Wno-unknown-pragmas -Wno-reorder
	# Enable even more warnings...
	CXXFLAGS+= -Wpointer-arith -Wcast-qual
	CXXFLAGS+= -Wshadow -Wnon-virtual-dtor -Wwrite-strings

	# Currently we disable this gcc flag, since it will also warn in cases,
	# where using GCC_PRINTF (means: __attribute__((format(printf, x, y))))
	# is not possible, thus it would fail compiliation with -Werror without
	# being helpful.
	#CXXFLAGS+= -Wmissing-format-attribute

ifneq "$(HAVE_CLANG)" "1"
	# enable checking of pointers returned by "new", but only when we do not
	# build with clang
	CXXFLAGS+= -fcheck-new
endif
endif

ifeq "$(HAVE_CLANG)" "1"
	CXXFLAGS+= -Wno-conversion -Wno-shorten-64-to-32 -Wno-sign-compare -Wno-four-char-constants
endif

#######################################################################
# Default commands - put the necessary replacements in config.mk      #
#######################################################################

CAT     ?= cat
CP      ?= cp
ECHO    ?= printf
INSTALL ?= install
MKDIR   ?= mkdir -p
RM      ?= rm -f
RM_REC  ?= $(RM) -r
ZIP     ?= zip -q

#######################################################################

include $(srcdir)/Makefile.common

# check if configure has been run or has been changed since last run
config.h config.mk: $(srcdir)/configure
ifeq "$(findstring config.mk,$(MAKEFILE_LIST))" "config.mk"
	@echo "Running $(srcdir)/configure with the last specified parameters"
	@sleep 2
	LDFLAGS="$(SAVED_LDFLAGS)" CXX="$(SAVED_CXX)" \
			CXXFLAGS="$(SAVED_CXXFLAGS)" CPPFLAGS="$(SAVED_CPPFLAGS)" \
			ASFLAGS="$(SAVED_ASFLAGS)" WINDRESFLAGS="$(SAVED_WINDRESFLAGS)" \
			$(srcdir)/configure $(SAVED_CONFIGFLAGS)
else
	$(error You need to run $(srcdir)/configure before you can run make. Check $(srcdir)/configure --help for a list of parameters)
endif


#
# Windows specific
#

scummvmtoolswinres.o: $(srcdir)/gui/media/scummvmtools.ico $(srcdir)/dists/scummvmtools.rc
	$(QUIET_WINDRES)$(WINDRES) -DHAVE_CONFIG_H $(WINDRESFLAGS) $(DEFINES) -I. -I$(srcdir) $(srcdir)/dists/scummvmtools.rc scummvmtoolswinres.o

# Special target to create a win32 tools snapshot binary
WIN32PATH ?= build
win32dist:   all
	mkdir -p $(WIN32PATH)/graphics
	mkdir -p $(WIN32PATH)/tools/media
	cp $(srcdir)/gui/media/detaillogo.jpg $(WIN32PATH)/tools/media/
	cp $(srcdir)/gui/media/logo.jpg $(WIN32PATH)/tools/media/
	cp $(srcdir)/gui/media/tile.gif $(WIN32PATH)/tools/media/
	$(STRIP) construct_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE2)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(WIN32PATH)/tools/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT) -o $(WIN32PATH)/tools/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT) -o $(WIN32PATH)/tools/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT) -o $(WIN32PATH)/tools/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(WIN32PATH)/tools/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT) -o $(WIN32PATH)/tools/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(WIN32PATH)/tools/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(WIN32PATH)/tools/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(WIN32PATH)/tools/gob_loadcalc$(EXEEXT)
	$(STRIP) grim_animb2txt$(EXEEXT) -o $(WIN32PATH)/tools/grim_animb2txt$(EXEEXT)
	$(STRIP) grim_cosb2cos$(EXEEXT) -o $(WIN32PATH)/tools/grim_cosb2cos$(EXEEXT)
	$(STRIP) grim_diffr$(EXEEXT) -o $(WIN32PATH)/tools/grim_diffr$(EXEEXT)
	$(STRIP) grim_int2flt$(EXEEXT) -o $(WIN32PATH)/tools/grim_int2flt$(EXEEXT)
	$(STRIP) grim_meshb2obj$(EXEEXT) -o $(WIN32PATH)/tools/grim_meshb2obj$(EXEEXT)
	$(STRIP) grim_patchex$(EXEEXT) -o $(WIN32PATH)/tools/grim_patchex$(EXEEXT)
	$(STRIP) grim_set2fig$(EXEEXT) -o $(WIN32PATH)/tools/grim_set2fig$(EXEEXT)
	$(STRIP) grim_sklb2txt$(EXEEXT) -o $(WIN32PATH)/tools/grim_sklb2txt$(EXEEXT)
	$(STRIP) grim_unlab$(EXEEXT) -o $(WIN32PATH)/tools/grim_unlab$(EXEEXT)
	$(STRIP) grim_bm2bmp$(EXEEXT) -o $(WIN32PATH)/tools/grim_bm2bmp$(EXEEXT)
	$(STRIP) grim_delua$(EXEEXT) -o $(WIN32PATH)/tools/grim_delua$(EXEEXT)
	$(STRIP) grim_imc2wav$(EXEEXT) -o $(WIN32PATH)/tools/grim_imc2wav$(EXEEXT)
	$(STRIP) grim_luac$(EXEEXT) -o $(WIN32PATH)/tools/grim_luac$(EXEEXT)
	$(STRIP) grim_mklab$(EXEEXT) -o $(WIN32PATH)/tools/grim_mklab$(EXEEXT)
	$(STRIP) grim_patchr$(EXEEXT) -o $(WIN32PATH)/tools/grim_patchr$(EXEEXT)
	$(STRIP) grim_setb2set$(EXEEXT) -o $(WIN32PATH)/tools/grim_setb2set$(EXEEXT)
	$(STRIP) grim_til2bmp$(EXEEXT) -o $(WIN32PATH)/tools/grim_til2bmp$(EXEEXT)
	$(STRIP) grim_vima$(EXEEXT) -o $(WIN32PATH)/tools/grim_vima$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools-cli$(EXEEXT)
	cp $(srcdir)/*.bat $(WIN32PATH)/tools
	cp $(srcdir)/COPYING $(WIN32PATH)/tools/COPYING.txt
	cp $(srcdir)/COPYING.BSD2 $(WIN32PATH)/tools/COPYING_BSD2.txt
	cp $(srcdir)/COPYING.LUA $(WIN32PATH)/tools/COPYING_LUA.txt
	cp $(srcdir)/README $(WIN32PATH)/tools/README.txt
	cp $(srcdir)/NEWS $(WIN32PATH)/tools/NEWS.txt
	cp $(srcdir)/dists/win32/graphics/left.bmp $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/graphics/scummvm-install.ico $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/ScummVM?Tools.iss $(WIN32PATH)
	unix2dos $(WIN32PATH)/tools/*.txt

# Special target to create a win32 NSIS installer
WIN32BUILD=build
win32setup: all
	mkdir -p $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/COPYING          $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/COPYING.BSD2     $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/COPYING.LUA      $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/NEWS             $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/README           $(srcdir)/$(WIN32BUILD)
	unix2dos $(srcdir)/$(WIN32BUILD)/*.*
	$(STRIP) construct_mohawk$(EXEEXT)   -o $(srcdir)/$(WIN32BUILD)/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE2)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT)          -o $(srcdir)/$(WIN32BUILD)/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT)              -o $(srcdir)/$(WIN32BUILD)/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT)           -o $(srcdir)/$(WIN32BUILD)/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT)            -o $(srcdir)/$(WIN32BUILD)/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT)           -o $(srcdir)/$(WIN32BUILD)/desword2$(EXEEXT)
	$(STRIP) extract_hadesch$(EXEEXT)    -o $(srcdir)/$(WIN32BUILD)/extract_hadesch$(EXEEXT)
	$(STRIP) extract_lokalizator$(EXEEXT)    -o $(srcdir)/$(WIN32BUILD)/extract_lokalizator$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/extract_mohawk$(EXEEXT)
	$(STRIP) extract_ngi$(EXEEXT)        -o $(srcdir)/$(WIN32BUILD)/extract_ngi$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/gob_loadcalc$(EXEEXT)
	$(STRIP) grim_animb2txt$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/tools/grim_animb2txt$(EXEEXT)
	$(STRIP) grim_cosb2cos$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/tools/grim_cosb2cos$(EXEEXT)
	$(STRIP) grim_diffr$(EXEEXT)         -o $(srcdir)/$(WIN32BUILD)/tools/grim_diffr$(EXEEXT)
	$(STRIP) grim_int2flt$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/tools/grim_int2flt$(EXEEXT)
	$(STRIP) grim_meshb2obj$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/tools/grim_meshb2obj$(EXEEXT)
	$(STRIP) grim_patchex$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/tools/grim_patchex$(EXEEXT)
	$(STRIP) grim_set2fig$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/tools/grim_set2fig$(EXEEXT)
	$(STRIP) grim_sklb2txt$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/tools/grim_sklb2txt$(EXEEXT)
	$(STRIP) grim_unlab$(EXEEXT)         -o $(srcdir)/$(WIN32BUILD)/tools/grim_unlab$(EXEEXT)
	$(STRIP) grim_bm2bmp$(EXEEXT)        -o $(srcdir)/$(WIN32BUILD)/tools/grim_bm2bmp$(EXEEXT)
	$(STRIP) grim_delua$(EXEEXT)         -o $(srcdir)/$(WIN32BUILD)/tools/grim_delua$(EXEEXT)
	$(STRIP) grim_imc2wav$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/tools/grim_imc2wav$(EXEEXT)
	$(STRIP) grim_luac$(EXEEXT)          -o $(srcdir)/$(WIN32BUILD)/tools/grim_luac$(EXEEXT)
	$(STRIP) grim_mklab$(EXEEXT)         -o $(srcdir)/$(WIN32BUILD)/tools/grim_mklab$(EXEEXT)
	$(STRIP) grim_patchr$(EXEEXT)        -o $(srcdir)/$(WIN32BUILD)/tools/grim_patchr$(EXEEXT)
	$(STRIP) grim_setb2set$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/tools/grim_setb2set$(EXEEXT)
	$(STRIP) grim_til2bmp$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/tools/grim_til2bmp$(EXEEXT)
	$(STRIP) grim_vima$(EXEEXT)          -o $(srcdir)/$(WIN32BUILD)/tools/grim_vima$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT)  -o $(srcdir)/$(WIN32BUILD)/scummvm-tools-cli$(EXEEXT)
	makensis -V2 -Dtop_srcdir="../.." -Dtext_dir="../../$(WIN32BUILD)" -Dbuild_dir="../../$(WIN32BUILD)" $(srcdir)/dists/win32/scummvm-tools.nsi


#
# OS X specific
#

ifdef USE_VORBIS
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libvorbisfile.a $(STATICLIBPATH)/lib/libvorbis.a $(STATICLIBPATH)/lib/libvorbisenc.a $(STATICLIBPATH)/lib/libogg.a
endif

ifdef USE_FLAC
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libFLAC.a
endif

ifdef USE_MAD
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libmad.a
endif

ifdef USE_PNG
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libpng.a
endif

ifdef USE_ZLIB
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libz.a
endif


# Special target to create a static linked binaries for Mac OS X.
scummvm-tools-static: $(scummvm-tools_OBJS)
	$(CXX) $(LDFLAGS) -o scummvm-tools-static $(scummvm-tools_OBJS) \
		-framework AudioUnit -framework AudioToolbox -framework Carbon -framework CoreMIDI \
		$(WXSTATICLIBS) $(OSX_STATIC_LIBS)

scummvm-tools-cli-static: $(scummvm-tools-cli_OBJS)
	$(CXX) $(LDFLAGS) -o scummvm-tools-cli-static $(scummvm-tools-cli_OBJS) \
		-framework AudioUnit -framework AudioToolbox -framework Carbon -framework CoreMIDI \
		$(OSX_STATIC_LIBS)

bundle_name = ScummVM\ Tools.app
bundle: scummvm-tools-static
	mkdir -p $(bundle_name)
	mkdir -p $(bundle_name)/Contents
	mkdir -p $(bundle_name)/Contents/MacOS
	mkdir -p $(bundle_name)/Contents/Resources
	echo "APPL????" > $(bundle_name)/Contents/PkgInfo
	cp $(srcdir)/dists/macosx/Info.plist $(bundle_name)/Contents/
	cp $(srcdir)/gui/media/*.* $(bundle_name)/Contents/Resources
	cp scummvm-tools-static $(bundle_name)/Contents/MacOS/scummvm-tools

# Special target to create a snapshot disk image for Mac OS X
osxsnap: bundle scummvm-tools-cli-static
	mkdir ScummVM-Tools-snapshot
	cp $(srcdir)/COPYING ./ScummVM-Tools-snapshot/License\ \(GPL\)
	cp $(srcdir)/COPYING.BSD2 ./ScummVM-Tools-snapshot/License\ \(BSD2\)
	cp $(srcdir)/COPYING.LUA ./ScummVM-Tools-snapshot/License\ \(LUA\)
	cp $(srcdir)/NEWS ./ScummVM-Tools-snapshot/News
	cp $(srcdir)/README ./ScummVM-Tools-snapshot/ScummVM\ ReadMe
	$(XCODETOOLSPATH)/SetFile -t ttro -c ttxt ./ScummVM-Tools-snapshot/*
	$(XCODETOOLSPATH)/CpMac -r $(bundle_name) ./ScummVM-Tools-snapshot/
	cp scummvm-tools-cli-static ./ScummVM-Tools-snapshot/scummvm-tools-cli
	cp $(srcdir)/dists/macosx/DS_Store ./ScummVM-Tools-snapshot/.DS_Store
	$(XCODETOOLSPATH)/SetFile -a V ./ScummVM-Tools-snapshot/.DS_Store
	hdiutil create -ov -format UDZO -imagekey zlib-level=9 -fs HFS+ \
					-srcfolder ScummVM-Tools-snapshot \
					-volname "ScummVM Tools" \
					ScummVM-Tools-snapshot.dmg
	rm -rf ScummVM-snapshot


#
# AmigaOS specific
#
# Special target to create an AmigaOS snapshot installation.
amigaosdist: all
	mkdir -p $(AMIGAOSPATH)
	mkdir -p $(AMIGAOSPATH)/doc
	mkdir -p $(AMIGAOSPATH)/media
	# Install documents
	cp $(srcdir)/COPYING $(AMIGAOSPATH)/doc/
	cp $(srcdir)/COPYING.BSD2 $(AMIGAOSPATH)/doc/
	cp $(srcdir)/COPYING.LUA $(AMIGAOSPATH)/doc/
	cp $(srcdir)/COPYRIGHT $(AMIGAOSPATH)/doc/
	cp $(srcdir)/NEWS $(AMIGAOSPATH)/doc/
	cp $(srcdir)/README $(AMIGAOSPATH)/doc/
	cp $(srcdir)/TODO $(AMIGAOSPATH)/doc/
	# Install media files
	cp $(srcdir)/gui/media/detaillogo.jpg $(AMIGAOSPATH)/media/
	cp $(srcdir)/gui/media/logo.jpg $(AMIGAOSPATH)/media/
	cp $(srcdir)/gui/media/scummvmtools_128.png $(AMIGAOSPATH)/media/
	cp $(srcdir)/gui/media/tile.gif $(AMIGAOSPATH)/media/
	# Install icons
	cp ${srcdir}/gui/media/scummvm-tools.info $(AMIGAOSPATH)/scummvm-tools-cli.info
	cp ${srcdir}/gui/media/scummvm-tools_drawer.info $(AMIGAOSPATH)/media/
	# Install tools
	$(STRIP) construct_mohawk$(EXEEXT) -o $(AMIGAOSPATH)/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE2)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(AMIGAOSPATH)/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT) -o $(AMIGAOSPATH)/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT) -o $(AMIGAOSPATH)/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT) -o $(AMIGAOSPATH)/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(AMIGAOSPATH)/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT) -o $(AMIGAOSPATH)/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(AMIGAOSPATH)/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(AMIGAOSPATH)/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(AMIGAOSPATH)/extract_mohawk$(EXEEXT)
	$(STRIP) extract_ngi$(EXEEXT) -o $(AMIGAOSPATH)/extract_ngi$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(AMIGAOSPATH)/gob_loadcalc$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT) -o $(AMIGAOSPATH)/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(AMIGAOSPATH)/scummvm-tools-cli$(EXEEXT)
	$(STRIP) extract_hadesch$(EXEEXT) -o $(AMIGAOSPATH)/extract_hadesch$(EXEEXT)
	$(STRIP) extract_lokalizator$(EXEEXT) -o $(AMIGAOSPATH)/extract_lokalizator$(EXEEXT)


#
# RISC OS specific
#

ifdef QUIET
QUIET_ELF2AIF = @echo '   ' ELF2AIF '' $@;
endif

, := ,

# Special target to create an RISC OS snapshot installation
riscosdist: all riscosboot $(addprefix !ScummTool/bin/,$(addsuffix $(,)ff8,$(PROGRAMS)))
	cp ${srcdir}/dists/riscos/!Run,feb !ScummTool/!Run,feb
	cp ${srcdir}/dists/riscos/!Sprites,ff9 !ScummTool/!Sprites,ff9
	cp ${srcdir}/dists/riscos/!Sprites11,ff9 !ScummTool/!Sprites11,ff9
	cp $(srcdir)/README !ScummTool/!Help,fff
	cp $(srcdir)/COPYING !ScummTool/COPYING,fff
	cp $(srcdir)/COPYING.BSD2 !ScummTool/COPYING.BSD2,fff
	cp $(srcdir)/COPYING.LUA !ScummTool/COPYING.LUA,fff
	cp $(srcdir)/NEWS !ScummTool/NEWS,fff
ifeq "$(USE_WXWIDGETS)" "1"
	mkdir -p !ScummTool/bin/media
	cp $(srcdir)/gui/media/detaillogo.jpg !ScummTool/bin/media/detaillogo.jpg,c85
	cp $(srcdir)/gui/media/logo.jpg !ScummTool/bin/media/logo.jpg,c85
	cp $(srcdir)/gui/media/tile.gif !ScummTool/bin/media/tile.gif,695
endif

riscosboot:
	mkdir -p !ScummTool/bin
	cp ${srcdir}/dists/riscos/!Boot,feb !ScummTool/!Boot,feb
	rm -rf !ScummTool/bin/*,ff8

!ScummTool/bin/%,ff8: %$(EXEEXT)
	$(QUIET_ELF2AIF)elf2aif $(<) !ScummTool/bin/$*,ff8
	$(QUIET)echo "Set Alias\$$$* <ScummTool\$$Dir>.bin.$* %%*0" >> !ScummTool/!Boot,feb
