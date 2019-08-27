export CC = gcc
export CXX = g++
export CCFLAGS = -w -Wall
export LDFLAGS = -lm -fopenmp -pthread
export LIB_DIR = $(abspath lib)
export LIB_SOURCE = $(LIB_DIR)/PolSARproLib.c
export LIB_O = $(LIB_DIR)/PolSARproLib.o
export BIN = $(abspath ../bin)

SUBDIRS = \
	basis_change \
	bmp_process \
	calculator \
	calibration \
	data_convert \
	data_import \
	data_process_dual \
	data_process_mult \
	data_process_sngl \
	speckle_filter \
	tools

SUBDIRS2 = \
	PolSARap \
	PolSARproSIM \
	PolSARproSIMgr \
	PolSARproSIMsv \
	SVM

SUBDIRS3 = \
	map_algebra_psp/linux/map_algebra \
	map_algebra_satim/linux/map_algebra

all: subdirs subdirs2 subdirs3
.PHONY: all clean $(SUBDIRS) $(SUBDIRS2) $(SUBDIRS3)

$(LIB_O): $(LIB_SOURCE)
	$(CC) -c $< $(CCFLAGS) $(LDFLAGS) -o $@

subdirs: $(SUBDIRS)

$(SUBDIRS): $(LIB_O)
	mkdir -p $(addprefix $(BIN)/,$(SUBDIRS))
	$(MAKE) -C $@

subdirs2: $(SUBDIRS2)

$(SUBDIRS2): $(LIB_O)
	mkdir -p $(addprefix $(BIN)/,$(SUBDIRS2))
	$(MAKE) -C $@

subdirs3: $(SUBDIRS3)

$(SUBDIRS3):
	- mkdir $(BIN)/map_algebra
	$(MAKE) -C $@

clean:
	rm -rf $(LIB_O)
	rm -rf $(addsuffix /*.o,$(SUBDIRS))
	rm -rf $(addprefix $(BIN)/,$(SUBDIRS))
	rm -rf $(addsuffix /*.o,$(SUBDIRS2))
	rm -rf $(addprefix $(BIN)/,$(SUBDIRS2))
	rm -rf $(BIN)/map_algebra*
	rm -rf $(addsuffix /*.o,$(SUBDIRS3))
