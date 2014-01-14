#############################################################################
# Makefile for building: AGILE ASDC software GRID SCI
# Last modification: 2008-06-03  (Andrea Bulgarelli)
# Project:  AGILE ASDC
# Template: system
# Use make variable_name=' options ' to override the variables or make -e to
# override the file variables with the environment variables
# 		make CFLAGS='-g' or make prefix='/usr'
# Instructions:
# - if you want, modify the sections 1) and 2) but it is not necessary
# - modify the variables of the section 3): CFLAGS
# - in section 4), modify the following action:
#		* checkout: modify the project and option -r
#			cvs checkout -r TAG_NAME prj_name
#		* all: and or remove exe and lib prerequisite
#		* clean: add or remove the files and directories that should be cleaned
#		* install: add or remove the files and directories that should be installed
#		* uninstall: add or remove the files and directories that should be uninstalled
#############################################################################

SHELL = /bin/sh

SYSTEM=linux

####### 0) Common definition
# DISCOS Type is the different type of DISCoS operating mode
# EGSE_DISCOS is for the DISCoS at EGSE level
DISCOS_TYPE = EGSE_DISCOS
# EGSE_TE is for the DISCoS at TE level
#DISCOS_TYPE = TE_DISCOS
####### 1) Directories for the installation

# Prefix for each installed program. Only ABSOLUTE PATH
prefix=$(HOME)/ADC
exec_prefix=$(prefix)
# The directory to install the binary files in.
bindir=$(exec_prefix)/bin
# The directory to install the local configuration file.
datadir=$(exec_prefix)/share
# The directory to install the libraries in.
libdir=$(exec_prefix)/lib
# The directory to install the info files in.
infodir=$(exec_prefix)/info
# The directory to install the include files in.
includedir=$(exec_prefix)/include

####### 2) Directories
PRJ_DIR=Projects

INSTALL_SUBDIR=

export AGILE_LIBPIL_INCLUDE=$(exec_prefix)/include
export AGILE_LIBPIL_LIB=$(exec_prefix)/lib
export AGILE_LIBWCS_INCLUDE=$(exec_prefix)/include
export AGILE_LIBWCS_LIB=$(exec_prefix)/lib
export AGILE_LIBGRID_INCLUDE=$(exec_prefix)/include
export AGILE_LIBGRID_LIB=$(exec_prefix)/lib
export AGILE_CFITSIO_INCLUDE=$(CFITSIO)/include
export AGILE_CFITSIO_LIB=$(CFITSIO)/lib
export AGILE_CFITSIO_LIBNAME=lcfitsio
export AGILE_ROOTSYS_INCLUDE=$(ROOTSYS)/include
export AGILE_ROOTSYS_LIB=$(ROOTSYS)/lib

####### 3) Compiler, tools and options

#Insert the optional parameter to the compiler. The CFLAGS could be changed externally by the user
AR       = ar cqs
TAR      = tar -cf
GZIP     = gzip -9f
COPY     = cp -f
COPY_FILE= $(COPY) -p
COPY_DIR = $(COPY) -pR
DEL_FILE = rm -f
SYMLINK  = ln -sf
DEL_DIR  = rm -rf
MOVE     = mv -f
CHK_DIR_EXISTS= test -d
MKDIR    = mkdir -p
CVS = cvs -d${CVSROOT} checkout

ifeq ($(SYSTEM), linux)
        CFLAGS=
endif
ifeq ($(SYSTEM), linux64)
        CFLAGS   = "-fshort-double -m64"
endif
ifeq ($(SYSTEM), mac)
        CFLAGS   = "-m32"
endif


#CFLAGS   = "-fshort-double -m64"
#CFLAGS   = -m32
#GCC     = gcc-4.1
#CXX     = g++-4.1

CFLAGS  = -m64
GCC     = gcc
CXX     = g++



BUILD = -r BUILD20
BUILD =

####### 4) Build rules
all:
	$(MKDIR) $(exec_prefix)/$(INSTALL_SUBDIR)/share
	cd ./$(PRJ_DIR)/agile_wcs_lib	&&		$(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
	cd ./$(PRJ_DIR)/agile_pil_lib	&&		$(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
	cd ./$(PRJ_DIR)/agile_grid_lib	&&		$(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
	
ifeq ($(SYSTEM), linux)
	#	cd ./$(PRJ_DIR)/lb_log   	&&      	$(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
endif
	
	cd ./$(PRJ_DIR)/AGILE_scientific_analysis   	&&      	$(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
	
	cd ./$(PRJ_DIR)/scientific_analysis     &&      $(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install
	cd ./$(PRJ_DIR)/AG_multi2       &&              $(MAKE) GCC=$(GCC) CXX=$(CXX) SYSTEM=$(SYSTEM) CFLAGS=$(CFLAGS) prefix=$(prefix) install


	test -d $(exec_prefix)/scripts/ || $(MKDIR) $(exec_prefix)/scripts
	$(COPY_DIR) ./scripts/* $(exec_prefix)/scripts/	

 

checkout:
	test -d $(PRJ_DIR) || mkdir -p $(PRJ_DIR)
	cd ./$(PRJ_DIR) 	&&	$(CVS)  $(BUILD) agile_wcs_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)  $(BUILD) agile_pil_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)  $(BUILD) agile_grid_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)  $(BUILD) AGILE_scientific_analysis
	cd ./$(PRJ_DIR)         &&      $(CVS)  $(BUILD) lb_log	
	cd ./$(PRJ_DIR) 	&&	$(CVS) $(BUILD)  scientific_analysis
	cd ./$(PRJ_DIR) 	&&	$(CVS) $(BUILD)  AG_multi2
	
checkout_last:

	test -d $(PRJ_DIR) || mkdir -p $(PRJ_DIR)
	cd ./$(PRJ_DIR) 	&&	$(CVS)   agile_wcs_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)   agile_pil_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)   agile_grid_lib
	cd ./$(PRJ_DIR) 	&&	$(CVS)   AGILE_scientific_analysis
	cd ./$(PRJ_DIR)         &&      $(CVS)   lb_log
	cd ./$(PRJ_DIR) 	&&	$(CVS)   scientific_analysis
	cd ./$(PRJ_DIR) 	&&	$(CVS)   AG_multi2

#clean: delete all files from the current directory that are normally created by building the program.
clean:
	cd ./$(PRJ_DIR)/agile_wcs_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) clean
	cd ./$(PRJ_DIR)/agile_pil_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) clean
	cd ./$(PRJ_DIR)/agile_grid_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) clean
	cd ./$(PRJ_DIR)/AGILE_scientific_analysis	&&	$(MAKE) prefix=$(prefix) clean

#Delete all files from the current directory that are created by configuring or building the program.
distclean: 
	test $(PRJ_DIR) = . || $(DEL_DIR) $(PRJ_DIR)

#install: compile the program and copy the executables, libraries,
#and so on to the file names where they should reside for actual use.
install: all


#uninstall: delete all the installed files--the copies that the `install' target creates.
uninstall:

	cd ./$(PRJ_DIR)/agile_wcs_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) uninstall
	cd ./$(PRJ_DIR)/agile_pil_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) uninstall
	cd ./$(PRJ_DIR)/agile_grid_lib	&&	$(MAKE) CFLAGS=$(CFLAGS) prefix=$(prefix) uninstall
	cd ./$(PRJ_DIR)/AGILE_scientific_analysis	&&	$(MAKE) prefix=$(prefix) uninstall

