`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 04:41:15 PM
// Design Name: 
// Module Name: sync_r2w
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


module two_ff_sync#(parameter WIDTH = 4)(
    input clk, rst_n,
    input[WIDTH-1:0] d1,
    (* ASYNC_REG = "TRUE" *) output reg [WIDTH-1:0] qb
    );
    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] qa;
    always@(posedge clk) begin
        if (!rst_n) begin
           qa<=0;
           qb<=0;
        end
        else begin
            qa <= d1;
            qb <= qa;
        end
    end
endmodule
