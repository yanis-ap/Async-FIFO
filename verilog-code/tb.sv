`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 07:19:16 PM
// Design Name: 
// Module Name: tb
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


module tb();
    parameter DEPTH = 8;
    parameter WIDTH = 8;
    
    logic wclk = 0, rclk = 0;
    logic wrst_n, rrst_n;
    logic w_en, r_en;
    logic [WIDTH-1:0] data_in;
    logic [WIDTH-1:0] data_out;
    logic full, empty;

    // Asynchronous Clocks: 10ns wclk (100MHz), 27ns rclk (~37MHz)
    always #5 wclk = ~wclk;
    always #13.5 rclk = ~rclk;

    // 2. Instantiate the DUT
    top #(DEPTH, WIDTH) dut (.*); // SystemVerilog auto-port connection

    // 3. The Scoreboard (Golden Reference)
    logic [WIDTH-1:0] scb_queue [$]; // SV Queue
    logic [WIDTH-1:0] expected_data;

    // 4. SystemVerilog Assertions (SVA)
    // Assert that we never write when full
    property p_no_overflow;
        @(posedge wclk) disable iff (!wrst_n)
        (full) |-> !(w_en);
    endproperty
    assert property (p_no_overflow) else $error("SVA VIOLATION: Write while FULL!");

    // Assert that we never read when empty
    property p_no_underflow;
        @(posedge rclk) disable iff (!rrst_n)
        (empty) |-> !(r_en);
    endproperty
    assert property (p_no_underflow) else $error("SVA VIOLATION: Read while EMPTY!");

    // 5. Stimulus Tasks
// --- FWFT Write Task ---
//cover group
// --- Functional Coverage ---
    // This group samples automatically on every rising edge of the write clock
    covergroup fifo_cov @(posedge wclk);
        
        // Coverpoints: Track individual signals
        cp_full: coverpoint full {
            bins not_full = {0};
            bins is_full  = {1};
        }
        
        cp_wen: coverpoint w_en {
            bins write_off = {0};
            bins write_on  = {1};
        }

        // Cross Coverage: Track combinations!
        // This proves to the interviewer that you tested the overflow protection
        cross_overflow_attempt: cross cp_wen, cp_full {
            // We want to ensure we hit the state where w_en=1 AND full=1
            ignore_bins no_write = binsof(cp_wen.write_off);
        }
    endgroup
    
    // --- Read Domain Functional Coverage ---
    // Samples on every rising edge of the read clock
    covergroup fifo_rd_cov @(posedge rclk);
        
        cp_empty: coverpoint empty {
            bins not_empty = {0};
            bins is_empty  = {1};
        }
        
        cp_ren: coverpoint r_en {
            bins read_off = {0};
            bins read_on  = {1};
        }

        // Cross Coverage: Verifies underflow protection (Read attempted while empty)
        cross_underflow_attempt: cross cp_ren, cp_empty {
            ignore_bins no_read = binsof(cp_ren.read_off);
        }
    endgroup
    
    
    task write_data();
        @(negedge wclk); // 1. Align to the clock FIRST
        if (!full) begin
            w_en = 1'b1;
            data_in = $urandom_range(0, 255);
            scb_queue.push_back(data_in);
        end
        else w_en = 1'b0;
    endtask

    // --- FWFT Read Task ---
    task read_data();
        @(negedge rclk); // 1. Align to the clock FIRST
        if (!empty) begin
            // 2. FWFT: Data is already on the bus, check it immediately
            expected_data = scb_queue.pop_front();
            
            if (data_out !== expected_data) begin
                $display("ERROR: Expected %0h, Got %0h at time %0t", expected_data, data_out, $time);
            end else begin
                $display("PASS: Data match %0h", data_out);
            end
            
            // 3. Assert r_en so the RAM pointer advances on the NEXT clock edge
            r_en = 1'b1; 
        end
        else r_en = 1'b0;
    endtask

    fifo_cov cov_inst;
    fifo_rd_cov cov_rd_inst;
    // --- Main Test Sequence ---
    initial begin
        cov_inst = new();
        cov_rd_inst = new();
        // Initialize
        w_en = 0; r_en = 0; data_in = 0;
        wrst_n = 0; rrst_n = 0;
        #50;
        wrst_n = 1; rrst_n = 1;
        #50;
     // Test 1: Fill the FIFO completely
        $display("--- TEST 1: Fill FIFO ---");
        repeat (DEPTH) write_data();
        @(negedge wclk); w_en = 0; // Turn off after burst
        #100;
        // --- NEW TEST 4: Corner Case - Forceful Write while Full ---
        $display("--- CORNER TEST: Write while FULL ---");
        @(negedge wclk);
        w_en = 1'b1;                      // Force write enable high while full == 1
        data_in = 8'hAA;                  // Dummy data (do NOT push to scb_queue!)
        @(negedge wclk);                  // Clock ticks -> Covergroup samples (w_en=1, full=1)
        w_en = 1'b0;                      // Turn off
        #50;
        // Test 2: Read it back entirely
        $display("--- TEST 2: Empty FIFO ---");
        repeat (DEPTH) read_data();
        @(negedge rclk); r_en = 0; // Turn off after burst
        #100;
        // ==========================================
        // CORNER TEST B: Read while EMPTY (Underflow check)
        // ==========================================
        $display("--- CORNER TEST: Read while EMPTY ---");
        @(negedge rclk);
        r_en = 1'b1;      // Force read high while empty == 1
        @(negedge rclk);  // Sampled by cov_rd_inst
        r_en = 1'b0;
        #50;
        // Test 3: Concurrent Read/Write (Stress Test)
        $display("--- TEST 3: Stress Test ---");
        fork 
            // Thread 1: Write thread
            begin
                repeat (20) begin
                    if ($urandom() % 2 == 0) write_data();
                    else begin
                        @(negedge wclk); 
                        w_en = 0;
                    end
                end
                @(negedge wclk); w_en = 0;
            end
 
            // Thread 2: Read thread 
            begin
                repeat (100) begin
                    if ($urandom() % 2 == 0) read_data();
                    else begin
                        @(negedge rclk); 
                        r_en = 0;
                    end
                end
                @(negedge rclk); r_en = 0;
            end
        join
        #100;
        // ==========================================
        // COVERAGE REPORT
        // ==========================================
        $display("==================================================");
        $display("          DUAL-DOMAIN COVERAGE REPORT             ");
        $display("==================================================");
        $display("Write Domain Coverage (wclk) : %0.2f%%", cov_inst.get_inst_coverage());
        $display("Read Domain Coverage  (rclk) : %0.2f%%", cov_rd_inst.get_inst_coverage());
        $display("==================================================");

        $display("SIMULATION COMPLETE.");
        $finish;
        end
endmodule
