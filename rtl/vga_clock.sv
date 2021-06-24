`timescale 1ns / 1ns

module vga_clock
#(
    parameter int VIDEO_ID_CODE = 1
)
(
    input logic clk_33,
    output logic clk_pixel
);
generate
    case (VIDEO_ID_CODE)
        1:
	       clock_converter  #(21.625, 28.625, 1, 30) clk_cnv(.clk_in(clk_33), .clk_out(clk_pixel));
        2:
	       clock_converter  #(30, 25, 1, 30) clk_cnv(.clk_in(clk_33), .clk_out(clk_pixel));
        3:
            clock_converter  #(29.250, 15, 1, 30) clk_cnv(.clk_in(clk_33), .clk_out(clk_pixel));
        4:
            clock_converter  #(62.375, 7, 2, 30) clk_cnv(.clk_in(clk_33), .clk_out(clk_pixel));
    endcase
endgenerate
endmodule
