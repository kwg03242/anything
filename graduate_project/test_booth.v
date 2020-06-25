`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/09 02:03:54
// Design Name: 
// Module Name: test_booth
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


module test(
    input [11:0] in0,
    input [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    );
    wire [26:0] m;
    wire [37:0] l;    
    
    assign m={in0[7:0],11'b0,in1[7:0]};
    assign l=m*in2;
    
    wire [14:0] a [1:0];
    
    booth_real_signed4bit m0({1'b0,in2},in0[11:8],a[0]);
    booth_real_signed4bit m1({1'b0,in2},in1[11:8],a[1]);
    
    assign out0={4'b0,l[37:19]}+{a[0],8'b0};
    assign out1={4'b0,l[18:0]}+{a[1],8'b0};
    
endmodule
module mul1(
    input [11:0] in0,
    input [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    );
    wire signed [26:0] m;
    wire signed [37:0] l;    
    wire signed [11:0] in;
    
    assign in={1'b0,in2};
    assign m={in0[11:4],11'b0,in1[11:4]};
    assign l=m*in;
    
    wire [15:0] a [1:0];
    
    booth_real_unsigned4bit m0({1'b0,in2},in0[3:0],a[0]);
    booth_real_unsigned4bit m1({1'b0,in2},in1[3:0],a[1]);
    
    assign out0={l[37:19],4'b0}+{7'b0,a[0]};
    assign out1={l[18:0],4'b0}+{7'b0,a[1]}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mul2#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)
    (
    input [11:0] in0,
    input [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    );
    wire signed [26:0] m;
    wire signed [37:0] l;    
    wire signed [11:0] in;
    
    assign in={1'b0,in2};
    assign m={in0[11:4],11'b0,in1[11:4]};
    assign l=m*in;
    
    wire [15:0] a [1:0];
    
    booth_real_unsigned4bit m0({1'b0,in2},in0[3:0],a[0]);
    booth_real_unsigned4bit m1({1'b0,in2},in1[3:0],a[1]);
    
    assign out0={l[37:19],4'b0}+{7'b0,a[0]};
    assign out1={l[18:0],4'b0}+{7'b0,a[1]}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule

module mul3#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)
    (
    input [11:0] in0,
    input [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    );
    wire signed [27:0] m;
    wire signed [38:0] l;    
    wire signed [11:0] in;
    
    assign in={1'b0,in2};
    assign m={in0[11:3],11'b0,in1[11:4]};
    assign l=m*in;
    
    wire [14:0] b;
    wire [15:0] a;
    
    booth_real_unsigned3bit m0({1'b0,in2},in0[2:0],b);
    booth_real_unsigned4bit m1({1'b0,in2},in1[3:0],a);
    
    assign out0={l[38:19],3'b0}+{8'b0,b};
    assign out1={l[18:0],4'b0}+{7'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mul4#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)
    (
    input [11:0] in0,
    input [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    );
    wire signed [28:0] m;
    wire signed [39:0] l;    
    wire signed [11:0] in;
    
    assign in={1'b0,in2};
    assign m={in0[11:3],11'b0,in1[11:3]};
    assign l=m*in;
    
    wire [14:0] b;
    wire [14:0] a;
    
    booth_real_unsigned3bit m0({1'b0,in2},in0[2:0],b);
    booth_real_unsigned3bit m1({1'b0,in2},in1[2:0],a);
    
    assign out0={l[39:20],3'b0}+{8'b0,b};
    assign out1={l[19:0],3'b0}+{8'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mul5#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)
    (
    input signed [11:0] in0,
    input signed [11:0] in1,
    input [10:0] in2,
    output [22:0] out0,
    output [22:0] out1
    ); 
    wire signed [11:0] in;
    
    assign in={1'b0,in2};

    assign out0=in*in0;
    booth_12x11 b(in1,in2,out1);
    
endmodule
module mul6#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)
    (
    input signed[11:0] in0,
    input signed[11:0] in1,
    input signed[11:0] in2,
    output signed[22:0] out0,
    output signed[22:0] out1
    );
    wire signed [27:0] m;
    wire signed [38:0] l;    
    wire signed [11:0] in;
    assign in={1'b0,in2[10:0]};
    assign m={in0[11:3],11'b0,in1[11:4]};
    assign l=m*in;
    
    wire [14:0] b;
    wire [15:0] a;
    
    app_booth_real_unsigned3bit m0({1'b0,in2[10:0]},in0[2:0],b);
    app_booth_real_unsigned4bit m1({1'b0,in2[10:0]},in1[3:0],a);
    
    assign out0={l[38:19],3'b0}+{8'b0,b};
    assign out1={l[18:0],4'b0}+{7'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule

module mul7#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)

    (

    input signed[11:0] in0,

    input signed[11:0] in1,

    input signed[11:0] in2,

    output signed[22:0] out0,

    output signed[22:0] out1

    );

    wire signed [27:0] m;

    wire signed [38:0] l;    

    wire signed [11:0] in;

    

    assign in={1'b0,in2[10:0]};

    assign m={in0,11'b0,in1[11:7]};

    assign l=m*in;

    

    wire [18:0] a;

    

    booth_real_unsigned8bit m0(in,in1[6:0],a);

    

    assign out0=l[38:16];

    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;

    

endmodule
module mul8#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)

    (

    input signed [11:0] in0,

    input signed[11:0] in1,

    input signed[11:0] in2,

    output signed[22:0] out0,

    output signed[22:0] out1

    );

    wire signed [27:0] m;

    wire signed [38:0] l;    

    wire signed [11:0] in;

    

    assign in={1'b0,in2[10:0]};

    assign m={in0,11'b0,in1[11:7]};

    assign l=m*in;

    

    wire [18:0] a;

    

    app_booth_real_unsigned8bit m0({1'b0,in2[10:0]},in1[6:0],a);

    

    assign out0=l[38:16];

    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;

    

endmodule
module mul9#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)

    (

    input signed [11:0] in0,

    input signed[11:0] in1,

    input signed[11:0] in2,

    output signed[22:0] out0,

    output signed[22:0] out1

    );

    wire signed [27:0] m;

    wire signed [38:0] l;    

    wire signed [11:0] in;

    

    assign in={1'b0,in2[10:0]};

    assign m={in0,11'b0,in1[11:7]};

    assign l=m*in;

    

    wire [18:0] a;

    

    app_booth_real_unsigned8bit m0({1'b0,in2[10:0]},in1[6:0],a);

    

    assign out0=l[38:16];

    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;

    

endmodule