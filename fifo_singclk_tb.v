`timescale 1ns / 1ps

module tb_fifo_single_clk;

    // Inputs
    reg clk, rst;
    reg wr_en, rd_en;
    reg [7:0] buf_in;

    // Outputs
    wire [7:0] buf_out;
    wire buf_empty, buf_full;
    wire [7:0] fifo_counter;
    wire fifo_threshold;
    wire fifo_overflow, fifo_underflow;

    // Instantiate the FIFO module
    fifo_new_singleclk uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .buf_in(buf_in),
        .buf_out(buf_out),
        .buf_empty(buf_empty),
        .buf_full(buf_full),
        .fifo_counter(fifo_counter),
        .fifo_threshold(fifo_threshold),
        .fifo_overflow(fifo_overflow),
        .fifo_underflow(fifo_underflow)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
        $display("Starting FIFO Testbench...");
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, tb_fifo_single_clk);

        // Initialize
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        buf_in = 8'd0;

        // Reset
        #10 rst = 0;

        // -----------------------------
        // Write 10 bytes into FIFO
        // -----------------------------
        $display("Writing 10 bytes into FIFO");
        repeat (10) begin
            @(posedge clk);
            wr_en = 1;
            buf_in = buf_in + 1;
        end
        @(posedge clk);
        wr_en = 0;

        // -----------------------------
        // Read 5 bytes from FIFO
        // -----------------------------
        $display("Reading 5 bytes from FIFO");
        repeat (5) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        // -----------------------------
        // Write until FIFO is full (64 total)
        // -----------------------------
        $display("Filling FIFO to check full and overflow...");
        repeat (60) begin
            @(posedge clk);
            wr_en = 1;
            buf_in = buf_in + 1;
        end

        // Force one more write to trigger overflow
        @(posedge clk);
        wr_en = 1;
        buf_in = 8'hFF;

        @(posedge clk);
        wr_en = 0;

        // -----------------------------
        // Read all to empty FIFO
        // -----------------------------
        $display("Emptying FIFO to check empty and underflow...");
        repeat (65) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        // -----------------------------
        // Finish
        // -----------------------------
        @(posedge clk);
        $display("Testbench finished.");
        $finish;
    end

endmodule
