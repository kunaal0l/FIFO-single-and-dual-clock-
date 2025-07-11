`timescale 1ns / 1ps
module fifo_dual_clk(clk_r,clk_w,rst,buf_out,wr_en,rd_en,buf_empty,buf_full,buf_in,fifo_counter);
input rst,clk_r,clk_w,wr_en,rd_en;
input[7:0] buf_in;
output[7:0] buf_out;
output buf_empty,buf_full;//these are flags
output [7:0] fifo_counter;
reg [7:0] buf_out;
reg buf_empty,buf_full;
reg[7:0] fifo_counter;
reg[6:0] rd_ptr,wr_ptr;
reg[7:0] buf_mem[63:0];
always @(fifo_counter)begin
    buf_empty=(fifo_counter==0);
    buf_full=(fifo_counter==64);
end
always @(posedge clk_w,posedge rst)begin
    if(rst)
        fifo_counter<=0;
    else if((!buf_full && wr_en))
        fifo_counter<=fifo_counter+1;
//    else
//        fifo_counter<=fifo_counter;  
    end
always @(posedge clk_r)
    begin
        if(!buf_empty && rd_en)
            fifo_counter<=fifo_counter-1;
//        else
//            fifo_counter<=fifo_counter; 
    end 
always @(posedge clk_r ,posedge rst) begin
    if(rst)
        buf_out<=0;
    else begin
        if(rd_en && !buf_empty)
            buf_out<=buf_mem[rd_ptr];
        else 
            buf_out<=buf_out;
        end
    end
always @(posedge clk_w) begin
    
      if(wr_en && !buf_full)
            buf_mem[wr_ptr]<=buf_in;
      else 
            buf_mem[wr_ptr]<= buf_mem[wr_ptr];
        
    end
always @(posedge clk_w,posedge rst) begin
    if(rst)begin
        wr_ptr<=0;
        end
    else if(!buf_full && wr_en)
        wr_ptr<=wr_ptr+1;
    else 
        wr_ptr<=wr_ptr;
end
always @(posedge clk_r,posedge rst) begin
    if(rst)begin
        rd_ptr<=0;end
    else if(!buf_full && wr_en)
        rd_ptr<=rd_ptr+1;
    else 
        rd_ptr<=rd_ptr;
end    

endmodule
