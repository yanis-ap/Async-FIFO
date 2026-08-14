`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 04:09:40 PM
// Design Name: 
// Module Name: dual_port_ram
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

module dual_port_ram 
#(parameter SIZE=8,parameter PTR_WIDTH=4)
(
input wclk,w_en,
input full,
input[SIZE-1:0] wdata,
input[PTR_WIDTH-1:0] w_ptr,r_ptr, //read-write pointers but truncated its msb since we don't need that
output [SIZE-1:0] rdata
    );
    localparam DEPTH = 1 << (PTR_WIDTH-1);
    reg [SIZE-1:0] mem [0:DEPTH - 1];
    always@(posedge wclk) begin
      if (w_en & !full) mem[w_ptr[PTR_WIDTH-2:0]] <= wdata;
    end
    assign rdata = mem[r_ptr[PTR_WIDTH-2:0]];
endmodule
