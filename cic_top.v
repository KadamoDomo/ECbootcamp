`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 10:42:32
// Design Name: 
// Module Name: cic_top
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

//M=1 R=512 N=4
module cic_top #(
    parameter N=4,
    parameter R=512,
    parameter M=1,
    parameter Bin=2,
    parameter Bmax=38
)(
    input clk, 
    input reset, 
    input enable,
    input signed [Bin-1 :0] in, 
    output signed [Bmax-1 :Bmax-20] out, // 20MSB bits
    output reg outready
    );
    
    //INTEGRATORS (N=4)
    reg signed [Bmax-1 : 0] acc1, acc2, acc3, acc4;
    reg [8:0] counter;
    
    //integrators logic
    always@(posedge(clk)) begin
        if(reset)begin
            acc1 <= 0;  acc2 <= 0; acc3 <= 0;  acc4 <= 0;
        end else if(enable) begin
            acc1 <= acc1 + in;  //data bits (in) got signed extended automatically
            acc2 <= acc2 + acc1;
            acc3 <= acc3 + acc2;
            acc4 <= acc4 + acc3;
        end
    end
    
    //counter & outready
    always@(posedge(clk)) begin
        if(reset)begin
            counter <= 0; 
            outready <= 0;
        end else if(enable) begin
            if(counter == R-1)begin
                counter <= 0;
                outready <= 1;
            end else begin
                counter <= counter+1; 
                outready <= 0;
            end
        end
    end
    
    //DOWNSAMPLER
    //handled with Rth bit pushing into prev1;
    
    
    //COMB STAGES
    reg signed [Bmax-1 : 0] comb1, comb2, comb3, comb4;
    reg signed [Bmax-1 : 0] prev1, prev2, prev3, prev4;
    
    //diff logic
    always@(posedge(clk)) begin
        if(reset) begin
            comb1 <= 0; comb2 <= 0; comb3 <= 0; comb4 <= 0;
             prev1<=0;    prev2<=0;   prev3<=0;   prev4<=0;          
        end else if(outready) begin
            prev1 <= acc4;  comb1 <= acc4 - prev1; //newly fed acc - prev value
            prev2 <= comb1; comb2 <= comb1 - prev2;
            prev3 <= comb2; comb3 <= comb2 - prev3;
            prev4 <= comb3; comb4 <= comb3 - prev4;
        end
    end
    
    assign out = comb4[Bmax-1 : Bmax-20];
endmodule
