`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 06:25:08 PM
// Design Name: 
// Module Name: top
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


module top#(parameter DEPTH = 8, parameter WIDTH = 8)
(
input wclk,rclk,
input wrst_n,rrst_n,
input w_en,r_en,
input [WIDTH-1:0] data_in,
output [WIDTH-1:0] data_out,
output full,empty
    );
    
    localparam PTR_WIDTH = 1 + $clog2(DEPTH);
    wire [PTR_WIDTH-1:0] g_wptr_sync, g_rptr_sync;
    wire [PTR_WIDTH-1:0] b_wptr, b_rptr;
    wire [PTR_WIDTH-1:0] g_wptr, g_rptr;
    
    two_ff_sync #(PTR_WIDTH) sync_r2w(.clk(wclk),.rst_n(rrst_n),.d1(g_rptr),.qb(g_rptr_sync));
    
    two_ff_sync #(PTR_WIDTH) sync_w2r(.clk(rclk),.rst_n(wrst_n),.d1(g_wptr),.qb(g_wptr_sync));
    
    wr_ptr_handler #(PTR_WIDTH) whandler(.wclk(wclk),.wrst_n(wrst_n),.w_en(w_en),
                                        .g_rptr_sync(g_rptr_sync),.b_wptr(b_wptr),
                                        .g_wptr(g_wptr),.full(full));
                                        
    rd_ptr_handler #(PTR_WIDTH) rhandler(.rclk(rclk),.rrst_n(rrst_n),.r_en(r_en),
                                        .g_wptr_sync(g_wptr_sync),.b_rptr(b_rptr),
                                        .g_rptr(g_rptr),.empty(empty));
                                        
    dual_port_ram #(WIDTH,PTR_WIDTH) fifo(.wclk(wclk),.w_en(w_en),
                                         .full(full),.wdata(data_in),
                                         .w_ptr(b_wptr),.r_ptr(b_rptr),
                                         .rdata(data_out));                                                                  
endmodule
