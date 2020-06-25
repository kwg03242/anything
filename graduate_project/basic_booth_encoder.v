`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/07 23:01:06
// Design Name: 
// Module Name: basic_booth_encoder
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


module basic_booth_encoder(
    input [2:0] in,
    output neg,
    output two,
    output zero
    );
    assign zero=(in==3'b0||in==3'b111);
    assign neg=in[2]&(~(in[1]&in[0]));
    assign two=in[2]? ~(in[1]|in[0]):in[1]&in[0];
endmodule

module basic_booth_encoder_first(
    input [1:0] in,
    output neg,
    output two,
    output zero
    );
    assign zero=(in==2'b0);
    assign neg=in[1];
    assign two=(in==2'b10);
endmodule

module basic_booth_encoder_last(
    input [1:0] in,
    output two,
    output zero
    );
    assign zero=(in==2'b0);
    assign two=(in==2'b11);
endmodule