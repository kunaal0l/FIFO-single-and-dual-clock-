`timescale 1ns / 1ps

module fifo_tb;

    // Inputs
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] buf_in;

    // Outputs
    wire [7:0] buf_out;
    wire buf_empty;
    wire buf_full;
    wire [7:0] fifo_counter;

    // Instantiate the FIFO module
    fifo_single_clk uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .buf_in(buf_in),
        .buf_out(buf_out),
        .buf_empty(buf_empty),
        .buf_full(buf_full),
        .fifo_counter(fifo_counter)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    // Test sequence
    initial begin
        // Initial setup
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        buf_in = 8'd0;

        // Apply reset
        #10;
        rst = 0;

        // Write 64 values into the FIFO
        $display("Filling the FIFO...");
        repeat(64) begin
            @(posedge clk);
            wr_en = 1;
            rd_en = 0;
            buf_in = buf_in + 1;
        end

        // Stop writing
        @(posedge clk);
        wr_en = 0;

        // Wait and check if buffer is full
        #10;
        if (buf_full)
            $display("Buffer is full at time %0t", $time);
        else
            $display("Buffer should be full, but it's not at time %0t", $time);

        // Read all 64 values from the FIFO
        $display("Emptying the FIFO...");
        repeat(64) begin
            @(posedge clk);
            wr_en = 0;
            rd_en = 1;
        end

        // Stop reading
        @(posedge clk);
        rd_en = 0;

        // Wait and check if buffer is empty
        #10;
        if (buf_empty)
            $display("Buffer is empty at time %0t", $time);
        else
            $display("Buffer should be empty, but it's not at time %0t", $time);

        #20;
        $finish;
    end

    // Monitor for observing behavior
    initial begin
        $monitor("Time=%0t | wr_en=%b rd_en=%b buf_in=%h buf_out=%h buf_full=%b buf_empty=%b fifo_counter=%d",
                 $time, wr_en, rd_en, buf_in, buf_out, buf_full, buf_empty, fifo_counter);
    end

endmodule

