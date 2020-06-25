`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/19 01:38:10
// Design Name: 
// Module Name: booth_source
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


module booth_encoder1(
    input [1:0] in,
    output [1:0] sig
    );
    assign sig[1]=in[1]^in[0];
    assign sig[0]=in[1]&in[0];
endmodule

module booth_encoder2(
    input [1:0] in,
    output [2:0] sig
    );
    assign sig[2]=in[1];
    assign sig[1]=in[0];
    assign sig[0]=(~in[0])&in[1];
endmodule
module booth_encoder3(
    input [2:0] in,
    output [2:0] sig
    );
    assign sig[2]=in[2];
    assign sig[1]=in[0]^in[1];
    assign sig[0]=~((in[2]~^in[1])|sig[1]);
endmodule
module booth_decoder1(
    input [11:0] in,
    input [1:0] sig,
    output [12:0] out
    );
    assign out=({in,1'b0}&{13{sig[0]}})|({in[11],in}&{13{sig[1]}});
endmodule
module booth_decoder2(
    input [11:0] in,
    input [2:0] sig,
    output [12:0] out
    );
    assign out=(({in,1'b0}&{13{sig[0]}})|({in[11],in}&{13{sig[1]}}))^{13{sig[2]}};
endmodule

module booth_real3(
    input [11:0] in0,
    input [3:0] in1,
    output [15:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2 [1:0];
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2[0]);
    booth_decoder2 bd2(in0,sig2[0],p[0]);
    booth_encoder3 be3(in1[3:1],sig2[1]);
    booth_decoder2 bd3(in0,sig2[1],p[1]);
    
    assign out={{{12{in1[3]}}&in0},4'b0}+{~p[0][12],{2{p[0][12]}},p[0]}+{~p[1][12],p[1],2'b0}+{13'b0,sig2[1][2],1'b0,sig2[0][2]};
    
endmodule

module booth_real(
    input [11:0] in0,
    input [2:0] in1,
    output [14:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2;
    
    booth_encoder1 be1(in1[2:1],sig1);
    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2);
    booth_decoder2 bd2(in0,sig2,p[1]);
    assign out={p[0],2'b0}+{{2{p[1][12]}},p[1]}+{14'b0,sig2[1]};
    
endmodule
module booth_real1(
    input [11:0] in0,
    input [1:0] in1,
    output [13:0] out
    );
    wire [12:0] p;
    wire [2:0] sig2;

    booth_encoder2 be2(in1[1:0],sig2);
    booth_decoder2 bd2(in0,sig2,p);
    assign out={p[12],p}+{14{in1[1]}}&{{2{in0[11]}},in0}+{13'b0,sig2[2]};
    
endmodule
module booth_real2(
    input [11:0] in0,
    input [1:0] in1,
    output [13:0] out
    );
    wire [12:0] p;
    wire [2:0] sig2;

    booth_encoder2 be2(in1[1:0],sig2);
    booth_decoder2 bd2(in0,sig2,p);
    assign out={p[12],p}+{{{12{in1[1]}}&{in0}},2'b0}+{13'b0,sig2[2]};
    
endmodule
module booth_real4(
    input [11:0] in0,
    input [2:0] in1,
    output [14:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2;

    booth_encoder2 be2(in1[1:0],sig2);
    booth_decoder2 bd2(in0,sig2,p[0]);
    booth_encoder1 be1(in1[2:1],sig1);
    booth_decoder1 bd1(in0,sig1,p[1]);
    
    assign out={{2{p[0][12]}},p[0]}+{p[1],2'b0}+{14'b0,sig2[2]};
    
endmodule
module booth1(
    input [11:0] in0,
    input [1:0] in1,
    output [12:0] out
    );
    assign out=(in1==2'b00)? 13'b0:(in1[1]^in1[0]==1'b1)? {in0[11],in0}:{in0,1'b0};
endmodule

module booth2(
    input [11:0] in0,
    input [1:0] in1,
    output [12:0] out
    );
    assign out=(in1==2'b00)? 13'b0:(in1==2'b1)? {in0[11],in0}:(in1==2'b10)? {~in0,1'b1}+13'b1:{~in0[11],~in0}+13'b1;
endmodule

module booth_real_signed4bit(
    input [11:0] in0,
    input [3:0] in1,
    output [14:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2 [1:0];
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2[0]);
    booth_decoder2 bd2(in0,sig2[0],p[0]);
    booth_encoder3 be3(in1[3:1],sig2[1]);
    booth_decoder2 bd3(in0,sig2[1],p[1]);
    
    assign out={{2{p[0][12]}},p[0]}+{p[1],2'b0}+{12'b0,sig2[1][2],1'b0,sig2[0][2]};
    
endmodule
module booth_real_unsigned4bit(
    input [11:0] in0,
    input [3:0] in1,
    output [15:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2 [1:0];
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2[0]);
    booth_decoder2 bd2(in0,sig2[0],p[0]);
    booth_encoder3 be3(in1[3:1],sig2[1]);
    booth_decoder2 bd3(in0,sig2[1],p[1]);
    
    assign out={{{12{in1[3]}}&in0},4'b0}+{~p[0][12],{2{p[0][12]}},p[0]}+{~p[1][12],p[1],2'b0}+{13'b0,sig2[1][2],1'b0,sig2[0][2]};
    
endmodule
module booth_real_unsigned3bit(
    input [11:0] in0,
    input [2:0] in1,
    output [14:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2;
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2);
    booth_decoder2 bd2(in0,sig2,p[0]);
    booth_encoder1 be3(in1[2:1],sig1);
    booth_decoder1 bd3(in0,sig1,p[1]);
    
    assign out={{2{p[0][12]}},p[0]}+{p[1],2'b0}+{14'b0,sig2[2]};
    
endmodule
module app_booth_real_unsigned4bit(
    input [11:0] in0,
    input [3:0] in1,
    output [15:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2 [1:0];
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2[0]);
    app_booth_decoder2#(12,4) bd2(in0,sig2[0],p[0]);
    booth_encoder3 be3(in1[3:1],sig2[1]);
    app_booth_decoder2#(12,2) bd3(in0,sig2[1],p[1]);
    
    assign out[15:4]={{{12{in1[3]}}&in0}}+{~p[0][12],{2{p[0][12]}},p[0][12:4]}+{~p[1][12],p[1][12:2]};
    assign out[3:0]={(p[1][1]|p[0][3]),(p[1][0]|p[0][2]),p[0][1],p[0][0]};
    
endmodule
module app_booth_real_unsigned3bit(
    input [11:0] in0,
    input [2:0] in1,
    output [14:0] out
    );
    wire [12:0] p [1:0];
    wire [1:0] sig1;
    wire [2:0] sig2;
    
//    booth_encoder1 be1(in1[4:3],sig1);
//    booth_decoder1 bd1(in0,sig1,p[0]);
    booth_encoder2 be2(in1[1:0],sig2);
    app_booth_decoder2#(12,4) bd2(in0,sig2,p[0]);
    booth_encoder1 be3(in1[2:1],sig1);
    app_booth_decoder1#(12,2) bd3(in0,sig1,p[1]);
    
    assign out[14:4]={{2{p[0][12]}},p[0][12:4]}+{p[1][12:2]};
    assign out[3:0]={(p[1][1]|p[0][3]),(p[1][0]|p[0][2]),p[0][1],p[0][0]};
    
endmodule
module booth_real_unsigned8bit(

    input [11:0] in0,

    input [6:0] in1,

    output [18:0] out

    );

    wire [12:0] p [3:0];

    wire [2:0] sig2 [2:0];

    wire [1:0] sig1;

    booth_encoder2 be1(in1[1:0],sig2[0]);

    booth_decoder2 bd1(in0,sig2[0],p[0]);


    booth_encoder3 be2(in1[3:1],sig2[1]);

    booth_decoder2 bd2(in0,sig2[1],p[1]);

    booth_encoder3 be3(in1[5:3],sig2[2]);

    booth_decoder2 bd3(in0,sig2[2],p[2]);

    booth_encoder1 be4(in1[6:5],sig1);

    booth_decoder1 bd4(in0,sig1,p[3]);
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
    +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_booth_real_unsigned8bit#(parameter WIDTH=12,P=6)(

    input [11:0] in0,

    input [6:0] in1,

    output [18:0] out

    );

    wire [12:0] p [3:0];

    wire [2:0] sig2 [2:0];

    wire [1:0] sig1;
    
    wire [18:0] out1;
    
    booth_encoder2 be1(in1[1:0],sig2[0]);

    app_booth_decoder2#(12,8) bd1(in0,sig2[0],p[0]);


    booth_encoder3 be2(in1[3:1],sig2[1]);

    app_booth_decoder2#(12,6) bd2(in0,sig2[1],p[1]);

    booth_encoder3 be3(in1[5:3],sig2[2]);

    app_booth_decoder2#(12,4) bd3(in0,sig2[2],p[2]);

    booth_encoder1 be4(in1[6:5],sig1);

    booth_decoder1 bd4(in0,sig1,p[3]);
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
        +{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
//        assign out1[18:6]={3'b0,~p[0][12],{2{p[0][12]}},p[0][12:6]}+{3'b1,~p[1][12],p[1][12:4]}+{1'b1,~p[2][12],p[2][12:2]}+{p[3]};
////+{13'b0,1'b0,sig2[2][2]});//,1'b0,sig2[1][2],1'b0,sig2[0][2]};
//    assign out1[5:0]={(p[2][1]|p[1][3]|p[0][5]),(p[2][0]|p[1][2]|p[0][4]),(p[1][1]|p[0][3]),(p[1][0]|p[0][2]),p[0][1],p[0][0]};
//    assign out=out1+{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_booth_decoder1#(parameter WIDTH=12, P=0)(
    input [WIDTH-1:0] in,
    input [1:0] sig,
    output [WIDTH:0] out
    );
    assign out[WIDTH:P]=({P>0? in[WIDTH-1: P-1]:{in,1'b0}}&{(WIDTH+1-P){sig[0]}})|({in[WIDTH-1],in[WIDTH-1:P]}&{(WIDTH+1-P){sig[1]}});
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=in[P-1-i]&sig[1];
        end
    endgenerate
endmodule
module app_booth_decoder2#(parameter WIDTH=12, P=0)(
    input [WIDTH-1:0] in,
    input [2:0] sig,
    output [WIDTH:0] out
    );
    
    assign out[WIDTH:P]=(({P>0? in[WIDTH-1: P-1]:{in,1'b0}}&{(WIDTH+1-P){sig[0]}})|({in[WIDTH-1],in[WIDTH-1:P]}&{(WIDTH+1-P){sig[1]}}))^{(WIDTH+1-P){sig[2]}};
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=(in[P-1-i]^sig[2]);
        end
    endgenerate
endmodule
module app1_booth_decoder1#(parameter WIDTH=12, P=0)(
    input [WIDTH-1:0] in,
    input [1:0] sig,
    output [WIDTH:0] out
    );
    assign out[WIDTH:P]=({P>0? in[WIDTH-1: P-1]:{in,1'b0}}&{(WIDTH+1-P){sig[0]}})|({in[WIDTH-1],in[WIDTH-1:P]}&{(WIDTH+1-P){sig[1]}});
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=in[P-1-i]&sig[1];
        end
    endgenerate
endmodule
module app1_booth_decoder2#(parameter WIDTH=12, P=0)(
    input [WIDTH-1:0] in,
    input [2:0] sig,
    output [WIDTH:0] out
    );
    
    assign out[WIDTH:P]=(({P>0? in[WIDTH-1: P-1]:{in,1'b0}}&{(WIDTH+1-P){sig[0]}})|({in[WIDTH-1],in[WIDTH-1:P]}&{(WIDTH+1-P){sig[1]}}))^{(WIDTH+1-P){sig[2]}};
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=(in[P-1-i]&sig[1])|(~in[P-1-i]&sig[2]);
        end
    endgenerate
endmodule
module app_1_booth_real_unsigned8bit#(parameter WIDTH=12,P=6)(

    input [11:0] in0,

    input [6:0] in1,

    output [18:0] out

    );

    wire [12:0] p [3:0];

    wire [2:0] sig2 [2:0];

    wire [1:0] sig1;

    new_be1 be1(in1[1:0],sig2[0]);

    app_new_bd#(4) bd1(in0,sig2[0],p[0]);


    new_be be2(in1[3:1],sig2[1]);

    app_new_bd#(2) bd2(in0,sig2[1],p[1]);

    new_be be3(in1[5:3],sig2[2]);

    new_bd bd3(in0,sig2[2],p[2]);

    booth_encoder1 be4(in1[6:5],sig1);

    booth_decoder1 bd4(in0,sig1,p[3]);
//        assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
//+{13'b0,1'b0,sig2[2][2],1'b0,sig2[1][2],1'b0,sig2[0][2]};
        assign out[18:4]=({3'b0,~p[0][12],{2{p[0][12]}},p[0][12:4]}+{3'b1,~p[1][12],p[1][12:2]}+{1'b1,~p[2][12],p[2]}+{p[3],2'b0}
+{13'b0,1'b0,sig2[2][2]});//,1'b0,sig2[1][2],1'b0,sig2[0][2]};
    assign out[3:0]={(p[1][1]|p[0][3]),(p[1][0]|p[0][2]|sig2[1][2]),p[0][1],p[0][0]|sig2[0][2]};
//    assign out[18:4]={3'b0,~p[0][12],{2{p[0][12]}},p[0][12:4]}+{3'b1,~p[1][12],p[1][12:2]}+{1'b1,~p[2][12],p[2]}+{p[3],2'b0}
//    +{13'b0,1'b0,sig2[2][2]};//,1'b0,sig2[1][2],1'b0,sig2[0][2]};
//    assign out[3:0]={(p[1][1]|p[0][3]),(p[1][0]|p[0][2]),p[0][1],p[0][0]};//+{1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module app_2_booth_real_unsigned8bit#(parameter WIDTH=12,P=6)(

    input [11:0] in0,

    input [6:0] in1,

    output [18:0] out

    );

    wire [12:0] p [3:0];
//    wire [14:0] m;

    wire [2:0] sig2 [2:0];

    wire [1:0] sig1;

    new_be1 be1(in1[1:0],sig2[0]);

    app_new_bd#(4) bd1(in0,sig2[0],p[0]);


    new_be be2(in1[3:1],sig2[1]);

    app_new_bd#(2) bd2(in0,sig2[1],p[1]);

    new_be be3(in1[5:3],sig2[2]);

    new_bd bd3(in0,sig2[2],p[2]);

    booth_encoder1 be4(in1[6:5],sig1);

    booth_decoder1 bd4(in0,sig1,p[3]);
    assign out={3'b0,~p[0][12],{2{p[0][12]}},p[0]}+{3'b1,~p[1][12],p[1],2'b0}+{1'b1,~p[2][12],p[2],4'b0}+{p[3],6'b0}
+{13'b0,1'b0,sig2[2][2],4'b0,1'b0,sig2[1][2],1'b0,sig2[0][2]};
endmodule
module one1 (
    input in0,
    input[11:0] in1,
    output [12:0] out
    );
    assign out[12]=in0;
    generate
        genvar i;
        for(i=0;i<12;i=i+1)begin:pp
            assign out[i]=in0^in1[i];
        end
    endgenerate
endmodule
module new_be(
    input[2:0] in,
    output [2:0] sig
    );
    assign sig[2]=in[2]&~(in[1]&in[0]);
    assign sig[1]=(in==3'b111||in==3'b0);
    assign sig[0]=(in==3'b011||in==3'b100);
endmodule
module new_be1(
    input[1:0] in,
    output [2:0] sig
    );
    assign sig[2]=in[1];
    assign sig[1]=~(in[1]|in[0]);
    assign sig[0]=in[1]&(~in[0]);
endmodule
module new_bd(
    input [11:0] in,
    input [2:0] sig,
    output [12:0] out
    );
    assign out=((sig[0]? {in,1'b0}:{in[11],in})^{13{sig[2]}})&{13{~sig[1]}};
endmodule
module app_new_bd#(parameter P=4)(
    input [11:0] in,
    input [2:0] sig,
    output [12:0] out
    );
    assign out[12:P]=/*(in[10:0]==11'b0)? {(13-P){1'b0}}:*/(((sig[0]? {(P>0? in[11:P-1]:{in,1'b0})}:{in[11],in[11:P]})^{(13-P){sig[2]}})&{(13-P){~sig[1]}});
    generate
        genvar i;
        for(i=0;i<P;i=i+1)begin:pp
            assign out[P-1-i]=(in[P-1-i]&sig[1])|(~in[P-1-i]&sig[2]);
        end
    endgenerate
endmodule