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

state = 0;
always @(posedge set or negedge reset_n or posedge clk)
begin
    done = 1'b0;
    if(state ==1)
    dout
    if (reset_n == 1'b0)
        dout <= 8'b00000000;
    else if (set == 1'b1)
        /// idont know
        begin
        if (valid == 1'b1)

            begin
                if (dec == 1'b0){
                idx_start = 8'b11001111 - ((din - 8'b01000001) << 3);
                idx_end = idx_start - 8'b00000111;
                }
                else{
                 
                }
                state=1;
                dout = idx_in[idx_start : idx_end];
                done = 1'b1;
            end
            
        end

end
endmodule