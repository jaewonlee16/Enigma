`timescale 1ns / 1ps

module reflector(
    input clk,
    input reset_n,
    input set,
    input [207:0] idx_in,
    input valid,
    input[7:0] din,
    input dec,
    output reg [7:0] dout,
    output reg done
);

    reg[7:0] idx_start, idx_end; 
    reg count = 1'b0;
    reg[7:0] dec_i = 8'b0;
    reg[7:0] tmp;
    reg[207:0] new_idx_in;
    integer i;
    parameter A = 8'b01000001;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            dout <= 8'b0; done <= 1'b0;
        end
        else if (count == 1'b1) begin dout <= tmp; done <= 1'b1; count <= 1'b0; end
        else if (count == 1'b0) done <= 0;  
    end
    
    always @(*) begin
        if(set == 1'b1) begin 
            for (i = 0; i < 208; i = i + 1) begin
                new_idx_in[i] <= idx_in[i];
            end
        end
        if(valid) begin
            if(dec == 1'b0) begin
                idx_start <= 8'b11001111 - ((din - A) << 3);
                tmp <= new_idx_in[idx_start -:8]; count <= 1'b1;
            end
            else begin
                for(i = 0; i < 26; i = i + 1) begin
                    if(new_idx_in[207 - 8*i -:8] == din[7:0])
                        dec_i = i;
                end
                tmp <= A + dec_i; count <= 1'b1;
            end
        end
    end
endmodule