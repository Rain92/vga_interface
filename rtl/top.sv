`timescale 1ns / 1ns

module top (
  input CLOCK_33,
  output logic LED_GREEN,
  output logic LED_RED,
  output logic[5:0] VGA_R,
  output logic[5:0] VGA_G,
  output logic[5:0] VGA_B,
  output logic VGA_HSYNC,
  output logic VGA_VSYNC,
  input PS2_CLOCK,
  input PS2_DATA  
);
    localparam CONTER_MAX = 33333333 - 1;
    
			 
    logic [31:0] counter;
    logic state;
    
   // assign LED_GREEN = state;
   // assign LED_RED = state;
    
    
    reg [15:0] write_addr, read_addr;
    reg [17:0] write_data;
    wire [17:0] read_data;
    reg write_en, read_en;
    		
	
    logic written = 0;
        
    reg video_active;
    reg [11:0] vga_x;
    reg [11:0] vga_y;
    
    logic video_active_;
    logic [11:0] vga_x_;
    logic [11:0] vga_y_;
    logic vga_hsync_;
    logic vga_vsync_;
    logic [11:0] VGA_SCREEN_WIDTH, VGA_SCREEN_HEIGHT;
    
    wire px_clk;
    
    always @(posedge px_clk) begin
        
        video_active <= video_active_;
        vga_x <= vga_x_;
        vga_y <= vga_y_;
        VGA_HSYNC <= vga_hsync_;
        VGA_VSYNC <= vga_vsync_;

    end
    
    initial begin
         counter = 0;
         state = 0;
         written = 0;
         write_addr = 0;
         write_data = 0;
         read_addr = 0;
         write_en = 0;
         read_en = 0;
    end

   
   memory #(
      .ADDR_WIDTH(16),
      .WORD_SIZE(18),
      .NUM_WORDS(256*192),
      .MEMORY_INIT_FILE("image_s.mem"),
      .USE_XILINX_BLOCKRAM(1)
   )
   memory_inst1 (
      .clk(px_clk),
      .write_en(write_en),
      .write_addr(write_addr),
      .write_data(write_data),
      
      .read_en(read_en),
      .read_addr(read_addr),
      .read_data(read_data)
   );

    logic [11:0] screen_width;
    logic [11:0] screen_height;

    vga_clock  #(.VIDEO_ID_CODE(3)) vga_clock_inst (.clk_33(CLOCK_33), .clk_pixel(px_clk));
    vga_timing_controller_preset #(.VIDEO_ID_CODE(3)) vga_0 (.clk_pixel(px_clk), .vga_hsync(vga_hsync_), .vga_vsync(vga_vsync_), 
                                           .vga_x(vga_x_), .vga_y(vga_y_), .video_active(video_active_), .screen_width(VGA_SCREEN_WIDTH), .screen_height(VGA_SCREEN_HEIGHT));
    
    
    
    logic font_set;
    
    logic [7:0] console_char;
    logic console_write;
    logic console_clear;
    
    vga_console #(
        .console_size_bits(5),
        .console_width(32),
        .console_height(16),
        .font_size_mult(4)
    ) 
    console (
        .clk_write(CLOCK_33),
        .append_char(console_char),
        .clear(console_clear),
        .pixel_x(vga_x),
        .pixel_y(vga_y),
        .font_set(font_set)
    );
    
    wire ascii_new;
    wire [7:0] ascii_code;
    
    ps2_keyboard_to_ascii #(
        .clk_freq(333333333),
        .ps2_debounce_counter_size(8)
    ) 
    keyboard (
        .clk(CLOCK_33),
        .ps2_clk(PS2_CLOCK),
        .ps2_data(PS2_DATA),
        .ascii_new(ascii_new),
        .ascii_code(ascii_code)
    );
    
    /* verilator lint_off LITENDIAN */
    logic[0:16*8-1] str = "Hello World!1234";
    
    
    always @ (posedge CLOCK_33) begin
        if (counter == CONTER_MAX) begin
            state <= ~state;
            counter <= 0;
            written <= 1;
        end
        else begin
            counter <= counter + 1;
        end
        
        if (ascii_new) begin
            console_char <= ascii_code;
            end
        else
            console_char <= 8'b0;
            
        LED_GREEN <= ascii_new;
        LED_RED <= ascii_code != 0;
        
        if (written == 0) begin
            if (counter == 0)
                console_clear <= 1;
            else
                console_clear <= 0;
                
           if ((counter > 0) && (counter < 17)) begin
                console_char <= str[(counter-1)*8 +: 8];
		   
           end
           else
                console_char <= 0;    
       end   
        
    end

	
    // rgb buffer
    always @(posedge px_clk) begin
        if (video_active_) begin
        
            read_addr <= {vga_y_[9:2], vga_x_[9:2]}; 
            read_en <= 1'b1;
            write_en <= 1'b0;
        end
        
        if (video_active) begin
        
            if (font_set)
                {VGA_R, VGA_G, VGA_B} <= 18'b0;
            else
                {VGA_R, VGA_G, VGA_B} <= read_data;
        end
        else begin
            {VGA_R, VGA_G, VGA_B} <= 18'b0;
        end
    end
            
endmodule
