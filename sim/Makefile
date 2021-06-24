ROOT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

PATH_DESIGN = $(ROOT_DIR)/../rtl
SOURCE_MAIN = vgasim_window.cpp
SOURCE_MAIN_V = top_sim.sv
MODULE_NAME = top_sim

FLAGS := -Wall -Wno-TIMESCALEMOD -Wno-UNUSED  --trace -cc 
CFLAGS := -Os
LDFLAGS  := -L$(ROOT_DIR)/minifb/build/ -lX11 -lminifb

all: vgasim_window vgasim_bitmap

vgasim_window:
	verilator -I$(PATH_DESIGN) $(FLAGS) -CFLAGS "$(CFLAGS)" -LDFLAGS "$(LDFLAGS)" $(SOURCE_MAIN_V) --exe vgasim_window.cpp --prefix Vvgasim_window
	make -C obj_dir -j  -f Vvgasim_window.mk Vvgasim_window

vgasim_bitmap:
	verilator -I$(PATH_DESIGN) $(FLAGS) -CFLAGS "$(CFLAGS)" $(SOURCE_MAIN_V) --exe vgasim_bitmap.cpp --prefix Vvgasim_bitmap
	make -C obj_dir -j  -f Vvgasim_bitmap.mk Vvgasim_bitmap


clean:
	rm -vfr obj_dir
