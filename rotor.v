`timescale 1ns / 1ps

module rotor(
    input clk,
    input reset_n,
    input set,
    input en,
    input valid,
    input rot,
    input[7:0] din,
    input[31:0] offset,
    input[31:0] delay,
    input[207:0] idx_in,
    input dec,
    output [7:0] dout,
    output reg done

);


count = 32'b000000000000000000000000000;
isValid = 1'b0;
always @(posedge clk)
begin
    if (valid == 1'b1)
    `   isValid = 1'b1;
    
    if (set == 1'b1)
        begin
            idx_in = {"변경된거"};
            begin
            if(isValid == 1'b1)
                count++;

            if (count == delay + 1)
                dout =      ;
                done = 1'b1;
        end
    end
end
endmodule