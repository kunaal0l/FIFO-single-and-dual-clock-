`timescale 1ns / 1ps
module fifo_single_clk(clk,rst,buf_out,wr_en,rd_en,buf_empty,buf_full,buf_in,fifo_counter,fifo_threshold ,fifo_overflow,fifo_underflow);
input rst,clk,wr_en,rd_en;
input[7:0] buf_in;
output[7:0] buf_out;
output buf_empty,buf_full;//these are flags
output [7:0] fifo_counter;
output reg fifo_threshold;
output reg fifo_overflow,fifo_underflow;
reg [7:0] buf_out;
reg buf_empty,buf_full;
reg[7:0] fifo_counter;
reg[6:0] rd_ptr,wr_ptr;
reg[7:0] buf_mem[63:0];
always @(fifo_counter)begin
    buf_empty=(fifo_counter==0);
    buf_full=(fifo_counter==64);
    fifo_threshold=(fifo_counter>=32);
end
always @(posedge clk,posedge rst)begin
    if(rst)
        fifo_counter<=0;
    else if((!buf_full && wr_en)&&(!buf_empty && rd_en))
        fifo_counter<=fifo_counter;
    else if(!buf_full && wr_en)
        fifo_counter<=fifo_counter+1;
    else if(!buf_empty && rd_en)
        fifo_counter<=fifo_counter-1;
    else
        fifo_counter<=fifo_counter;    
end
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_overflow  <= 0;
        fifo_underflow <= 0;
    end else begin
        if (wr_en && buf_full)
            fifo_overflow <= 1;
        else if (rd_en)
            fifo_overflow <= 0;
        if (rd_en && buf_empty)
            fifo_underflow <= 1;
        else if (wr_en)
            fifo_underflow <= 0;
    end
end
always @(posedge clk) begin
    if(rst)
        buf_out<=0;
    else begin
        if(rd_en && !buf_empty)
            buf_out<=buf_mem[rd_ptr];
        else 
            buf_out<=buf_out;
        end
    end
always @(posedge clk) begin
    if(rst)
        buf_out<=0;
    else begin
        if(wr_en && !buf_full)
            buf_mem[wr_ptr]<=buf_in;
        else 
            buf_mem[wr_ptr]<= buf_mem[wr_ptr];
        end
    end
always @(posedge clk,posedge rst) begin
    if(rst)begin
        wr_ptr<=0;
        rd_ptr<=0;end
    else begin
        if(wr_en && !buf_full)
            wr_ptr<=wr_ptr+1;
        else 
            wr_ptr<=wr_ptr;
        if(!buf_empty && rd_en)
            rd_ptr<=rd_ptr+1;
        else
            rd_ptr<=rd_ptr;
        end
    end   

endmodule
