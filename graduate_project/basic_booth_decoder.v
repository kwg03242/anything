`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/07 23:01:06
// Design Name: 
// Module Name: basic_booth_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module basic_booth_decoder(
    input zero,
    input two,
    input neg,
    input [11:0] in,
    output [12:0] out
    );
    assign out=((two? {in,1'b0}:{in[11],in})^{13{neg}})&{13{~zero}};
endmodule

module basic_booth_decoder_last(
    input zero,
    input two,
    input [11:0] in,
    output [12:0] out
    );
    assign out=((two? {in,1'b0}:{in[11],in}))&{13{~zero}};
endmodule
