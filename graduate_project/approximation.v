`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/22 01:04:18
// Design Name: 
// Module Name: approximation
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


module mac1(
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

    app_booth1 m0({1'b0,in2[10:0]},in1[6:0],a);

    assign out0=l[38:16];
    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mac2(
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

    app_booth2 m0({1'b0,in2[10:0]},in1[6:0],a);

    assign out0=l[38:16];
    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mac3(
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

    app_booth3 m0({1'b0,in2[10:0]},in1[6:0],a);

    assign out0=l[38:16];
    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module mac4#(parameter TOTAL_WIDTH = 14, FLOAT_WIDTH = 10, EXTRA_BITS_UPPER = 0 , EXTRA_BITS_LOWER = 10)(
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

    app_booth4 m0({1'b0,in2[10:0]},in1[6:0],a);

    assign out0=l[38:16];
    assign out1={l[15:0],7'b0}+{4'b0,a}+{~({11{in1[11]}}&in2),12'hfff}+23'b1;
    
endmodule
module app_booth1(
    input [11:0] in0,
    input [6:0] in1,
    output [18:0] out
    );
    wire [12:0] p [3:0];
    wire [2:0] sig2 [2:0];
    wire [1:0] sig1;

    booth_encoder2 be1(in1[1:0],sig2[0]);
    app_bd#(6) bd1(in0,sig2[0],p[0]);
    booth_encoder3 be2(in1[3:1],sig2[1]);
    app_bd#(4) bd2(in0,sig2[1],p[1]);
    booth_encoder3 be3(in1[5:3],sig2[2]);
    app_bd#(2) bd3(in0,sig2[2],p[2]);
    booth_encoder1 be4(in1[6:5],sig1);
    booth_decoder1 bd4(in0,sig1,p[3]);
    //app_bd#(0)
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
    +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_booth2(
    input [11:0] in0,
    input [6:0] in1,
    output [18:0] out
    );
    wire [12:0] p [3:0];
    wire [2:0] sig2 [2:0];
    wire [1:0] sig1;

    booth_encoder2 be1(in1[1:0],sig2[0]);
    app_bd#(8) bd1(in0,sig2[0],p[0]);
    booth_encoder3 be2(in1[3:1],sig2[1]);
    app_bd#(6) bd2(in0,sig2[1],p[1]);
    booth_encoder3 be3(in1[5:3],sig2[2]);
    app_bd#(4) bd3(in0,sig2[2],p[2]);
    booth_encoder1 be4(in1[6:5],sig1);
    booth_decoder1 bd4(in0,sig1,p[3]);
    //app_bd#(0)
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
    +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_booth3(
    input [11:0] in0,
    input [6:0] in1,
    output [18:0] out
    );
    wire [12:0] p [3:0];
    wire [2:0] sig2 [2:0];
    wire [1:0] sig1;

    booth_encoder2 be1(in1[1:0],sig2[0]);
    app_bd#(8) bd1(in0,sig2[0],p[0]);
    booth_encoder3 be2(in1[3:1],sig2[1]);
    app_bd#(6) bd2(in0,sig2[1],p[1]);
    booth_encoder3 be3(in1[5:3],sig2[2]);
    app_bd#(4) bd3(in0,sig2[2],p[2]);
    booth_encoder1 be4(in1[6:5],sig1);
    app_bd1#(2) bd4(in0,sig1,p[3]);
    //app_bd#(0)
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
    +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_booth4(
    input [11:0] in0,
    input [6:0] in1,
    output [18:0] out
    );
    wire [12:0] p [3:0];
    wire [2:0] sig2 [2:0];
    wire [1:0] sig1;

    booth_encoder2 be1(in1[1:0],sig2[0]);
    app_bd#(6) bd1(in0,sig2[0],p[0]);
    booth_encoder3 be2(in1[3:1],sig2[1]);
    app_bd#(4) bd2(in0,sig2[1],p[1]);
    booth_encoder3 be3(in1[5:3],sig2[2]);
    app_bd#(2) bd3(in0,sig2[2],p[2]);
    booth_encoder1 be4(in1[6:5],sig1);
    app_bd1#(0) bd4(in0,sig1,p[3]);
    //app_bd#(0)
        assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
    +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
//    assign out[18:4]={3'b0,~p[0][12],{2{p[0][12]}},p[0][12:4]}+{3'b1,~p[1][12],p[1][12:2]}+{1'b1,~p[2][12],p[2]}+{p[3],2'b0};
//    assign out[3:0]={(p[1][1]|p[0][3]),(p[1][0]|p[0][2]),p[0][1],p[0][0]};
endmodule
module app_bd#(parameter P=4)(
    input [11:0] in,
    input [2:0] sig,
    output [12:0] out
    );
   // assign out[12:P]=(((sig[0]? {(P>0? in[11:P-1]:{in,1'b0})}:{in[11],in[11:P]})^{(13-P){sig[2]}})&{(13-P){~sig[1]}});
   assign out[12:P]=(P==0)? (({in,1'b0}&{13{sig[0]}})|({in[11],in}&{13{sig[1]}}))^{13{sig[2]}}:
                            (({in[11:P-1]}&{(13-P){sig[0]}})|{in[11],in[11:P]}&{(13-P){sig[1]}})^{(13-P){sig[2]}};
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=sig[2]^in[P-1-i];
        end
    endgenerate
endmodule
module app_bd1#(parameter P=4)(
    input [11:0] in,
    input [1:0] sig,
    output [12:0] out
    );
    assign out[12:P]=(P==0)? ({in,1'b0}&{13{sig[0]}})|({in[11],in}&{13{sig[1]}}):
                        (({in[11:P-1]}&{(13-P){sig[0]}})|{in[11],in[11:P]}&{(13-P){sig[1]}});
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=in[P-1-i];
        end
    endgenerate                    
endmodule