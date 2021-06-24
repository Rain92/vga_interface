#include <fcntl.h>
#include <stdlib.h>
#include <vector>
#include "Vvgasim_bitmap.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "bitmap.h"

#define LOG(...) fprintf(stderr, __VA_ARGS__)

bool needDump = false; /* when the vsync signal transition from low to high */
bool old_hsync = true; /* hsync is useless since it's not moved during the vsync */
bool old_vsync = true;


VerilatedVcdC	*m_trace;
bool trace = true;

int main(int argc, char *argv[]) {
    LOG(" [+] starting VGA simulation\n");
    uint64_t tickcount = 0;

    Vvgasim_bitmap* vga = new Vvgasim_bitmap;

    if (trace)
    {
		Verilated::traceEverOn(true);
        m_trace = new VerilatedVcdC;
        vga->trace(m_trace, 99);
        m_trace->open("trace.vcd");
    }

    vga->CLOCK_33 = 0;
    vga->eval();


    int img_width = vga->VGA_SCREEN_WIDTH;
    int img_height = vga->VGA_SCREEN_HEIGHT;

    std::vector<uint8_t> image(img_width*img_height*3, 0);

    uint32_t idx = 0;
    

    for (unsigned int count_image = 0; count_image < 10; ) 
    {

        vga->CLOCK_33 = 0;
        vga->eval();

		if(trace) 
            m_trace->dump(10*tickcount);

        vga->CLOCK_33 = 1;
        vga->eval();

		if(trace) 
            m_trace->dump(10*tickcount+5);


        if(vga->VGA_ACTIVE)
        {
            image[idx++] = vga->VGA_B << 2;
            image[idx++] = vga->VGA_G << 2;
            image[idx++] = vga->VGA_R << 2;
        }


        /* we need to dump when vsync transitions from low to high */
        needDump = (!old_vsync && vga->VGA_VSYNC);

        if (needDump) {
            char filename[64];
            snprintf(filename, 63, "frames/frame-%08d.bmp", count_image++);
            LOG(" [-> dumping frame %s at idx %d]\n", filename, idx);
            
            generateBitmapImage(&image[0], img_height, img_width, filename);

            if(trace) 
            {
                m_trace->flush();
                trace = false;
            }

            idx = 0;
        }

        old_vsync = vga->VGA_VSYNC;
        old_hsync = vga->VGA_HSYNC;



        vga->CLOCK_33 = 0;
        vga->eval();


        tickcount++;
    }

    return EXIT_SUCCESS;
}
