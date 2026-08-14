`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 05:55:22 PM
// Design Name: 
// Module Name: wr_ptr_handler
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


module wr_ptr_handler #(parameter PTR_WIDTH=4) (
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH-1:0] g_rptr_sync,
  output reg [PTR_WIDTH-1:0] b_wptr, g_wptr,
  output reg full
);

  wire [PTR_WIDTH-1:0] b_wptr_next;
  wire [PTR_WIDTH-1:0] g_wptr_next;

  wire wfull;
  
  assign b_wptr_next = b_wptr+(w_en & !full);
  assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
      b_wptr <= 0; // set default value
      g_wptr <= 0;
      full   <= 0;
    end
    else begin
      b_wptr <= b_wptr_next; // incr binary write pointer
      g_wptr <= g_wptr_next; // incr gray write pointer
      full <= wfull;
    end
  end

  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH-1:PTR_WIDTH-2], g_rptr_sync[PTR_WIDTH-3:0]});

endmodule
