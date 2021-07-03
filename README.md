# vga_interface

A functional FPGA VGA and PS/2 Keyboard interface written in SystemVerilog including a console that lets you type text on a screen.

## Source
rtl/ includes the SystemVerilog logic and top level modules for a real FPGA and for simulation.
The ps/2 keyboard controller is based on https://forum.digikey.com/t/ps-2-keyboard-to-ascii-converter-vhdl/12616 and was portet to SystemVerilog.

## Project
project/ includes the Vivado project files targeting an ebaz4205 FPGA.

## Simulator
sim/ Includes 2 simulators based on Verilator.
One of them saves the output VGA frames as images.
The other one uses MiniFb (https://github.com/emoon/minifb) to display the VGA frames in real time in a window, it also includes a simulator for basic keyboard inputs.  

To run the simulator MiniFB has to be built first:

```
cd sim\minifb\build
mkdir build
cd build
cmake .. -DUSE_OPENGL_API=OFF -DUSE_WAYLAND_API=OFF
cd ../..
```

Then you can run the simulator with:
```
make && ./obj_dir/Vvgasim_window
```
