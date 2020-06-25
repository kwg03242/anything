`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/07 22:51:30
// Design Name: 
// Module Name: basic_booth
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


module basic_booth(
    input [11:0] in0,
    input [11:0] in1,
    output [22:0] out
    );
    genvar i;
    wire neg [5:0];
    wire zero [5:0];
    wire two [5:0];
    wire [12:0] pp [5:0];
    generate for(i=0;i<6;i=i+1)begin: booth
        if(i==0)begin
            basic_booth_encoder be({in1[1:0],1'b0},neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],in0,pp[i]);
        end
        else begin
            basic_booth_encoder be(in1[i*2+1:i*2-1],neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],in0,pp[i]);
        end
    end endgenerate
    assign out={7'b0,~pp[0][12],pp[0][12],pp[0][12],pp[0]}+{7'b1,~pp[1][12],pp[1],2'b0}+{5'b1,~pp[2][12],pp[2],4'b0}+{3'b1,~pp[3][12],pp[3],6'b0}+{1'b1,~pp[4][12],pp[4],8'b0}
                +{pp[5],10'b0}+{12'b0,neg[5],1'b0,neg[4],1'b0,neg[3],1'b0,neg[2],1'b0,neg[1],1'b0,neg[0]};
endmodule
module booth_12x11(
    input [11:0] in0,
    input [10:0] in1,
    output [22:0] out
    );
    genvar i;
    wire neg [4:0];
    wire zero [5:0];
    wire two [5:0];
    wire [12:0] pp [5:0];
    generate for(i=0;i<6;i=i+1)begin: booth
        if(i==0)begin
            basic_booth_encoder_first be({in1[1:0]},neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],in0,pp[i]);
        end
        else if(i==5)begin
            basic_booth_encoder_last be({in1[10:9]},two[i],zero[i]);
            basic_booth_decoder_last bd(zero[i],two[i],in0,pp[i]);
        end
        else begin
            basic_booth_encoder be(in1[i*2+1:i*2-1],neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],in0,pp[i]);
        end
    end endgenerate
    assign out={7'b0,~pp[0][12],pp[0][12],pp[0][12],pp[0]}+{7'b1,~pp[1][12],pp[1],2'b0}+{5'b1,~pp[2][12],pp[2],4'b0}+{3'b1,~pp[3][12],pp[3],6'b0}+{1'b1,~pp[4][12],pp[4],8'b0}
                +{pp[5],10'b0}+{13'b0,1'b0,neg[4],1'b0,neg[3],1'b0,neg[2],1'b0,neg[1],1'b0,neg[0]};
endmodule
module booth_11x12(
    input [10:0] in0,
    input [11:0] in1,
    output [22:0] out
    );
    genvar i;
    wire neg [5:0];
    wire zero [5:0];
    wire two [5:0];
    wire [12:0] pp [5:0];
    generate for(i=0;i<6;i=i+1)begin: booth
        if(i==0)begin
            basic_booth_encoder_first be({in1[1:0]},neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],{1'b0,in0},pp[i]);
        end
        else begin
            basic_booth_encoder be(in1[i*2+1:i*2-1],neg[i],two[i],zero[i]);
            basic_booth_decoder bd(zero[i],two[i],neg[i],{1'b0,in0},pp[i]);
        end
    end endgenerate
    assign out={7'b0,~pp[0][12],pp[0][12],pp[0][12],pp[0]}+{7'b1,~pp[1][12],pp[1],2'b0}+{5'b1,~pp[2][12],pp[2],4'b0}+{3'b1,~pp[3][12],pp[3],6'b0}+{1'b1,~pp[4][12],pp[4],8'b0}
                +{pp[5],10'b0}+{12'b0,neg[5],1'b0,neg[4],1'b0,neg[3],1'b0,neg[2],1'b0,neg[1],1'b0,neg[0]};
endmodule

module t(
    input signed [11:0] in0,
    input signed [11:0] in1,
    input signed [22:0] in2,
    output signed [23:0] out
    );
    
    assign out=in0*in1+in2;
    
endmodule