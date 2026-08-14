`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 06:11:26 PM
// Design Name: 
// Module Name: rd_ptr_handler
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


module rd_ptr_handler#(parameter PTR_WIDTH=4)(
  input rclk, rrst_n, r_en,
  input [PTR_WIDTH-1:0] g_wptr_sync,
  output reg [PTR_WIDTH-1:0] b_rptr, g_rptr,
  output reg empty
);

  wire [PTR_WIDTH-1:0] b_rptr_next;
  wire [PTR_WIDTH-1:0] g_rptr_next;

  wire rempty;
  
  assign b_rptr_next = b_rptr+(r_en & !empty);
  assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
  
  always@(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
      b_rptr <= 0; // set default value
      g_rptr <= 0;
      empty   <= 1'b1;
    end
    else begin
      b_rptr <= b_rptr_next; // incr binary write pointer
      g_rptr <= g_rptr_next; // incr gray write pointer
      empty <= rempty;
    end
  end

  assign rempty = (g_rptr_next == g_wptr_sync);
endmodule