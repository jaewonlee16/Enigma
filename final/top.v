`timescale 1ns / 1ps

module top(
    input clk,
    input reset_n,
    input set,
    input en,
    input valid,
    input[7:0] din,
    input dec,
    output[7:0] dout,
    output done,

    input[31:0] first_offset,
    input[31:0] second_offset,
    input[31:0] third_offset,
    input[31:0] first_delay,
    input[31:0] second_delay,
    input[31:0] third_delay,
    input[207:0] first_idx_in,
    input[207:0] second_idx_in,
    input[207:0] third_idx_in,
    input [207:0] reflector_idx_in
);

    wire[7:0] dout1, dout2, dout3, dout4;
    wire done1, done2, done3, done4, done1_, done2_, done3_;
    wire[7:0] din1, din2, din3, din4;
    wire valid1, valid2, valid3, valid4;
    reg direction = 1'b0, direction_ = 1'b0;
    reg[7:0] dout;
    reg done;

    always@ (posedge done4) begin
        direction <= 1'b1;
    end
    
    always@ (posedge done1) begin
        if (direction == 1'b1) begin dout <= dout1; done <= 1'b1; end
    end
    
    always@ (posedge clk) begin
        if (done == 1'b1) begin done <= 1'b0; direction <= 1'b0; end
        if (direction == 1'b0) direction_ <= 1'b0;
        else direction_ <= 1'b1;
    end

   
    mux mux_din1(clk, direction, {din, dout2}, din1);
    mux_1 mux_valid1(clk, direction, {valid, done2_}, valid1);
    rotor rotor1(clk, reset_n, set, en, valid1, rot, din1, first_offset, first_delay, first_idx_in, dec, dout1, done1);
    D_FF done1_d(clk, done1, done1_);
    
    mux mux_din2(clk, direction_, {dout1, dout3}, din2);
    mux_1 mux_valid2(clk, direction_, {done1_, done3_}, valid2);
    rotor rotor2(clk, reset_n, set, en, valid2, rot, din2, second_offset, second_delay, second_idx_in, dec, dout2, done2);
    D_FF done2_d(clk, done2, done2_);
    
    mux mux_din3(clk, direction, {dout2, dout4}, din3);
    mux_1 mux_valid3(clk, direction, {done2_, done4}, valid3);
    rotor rotor3(clk, reset_n, set, en, valid3, rot, din3, third_offset, third_delay, third_idx_in, dec, dout3, done3); 
    D_FF done3_d(clk, done3, done3_);
    
    mux_1 mux_valid4(clk, direction, {done3_, 1'b0}, valid4);
    reflector reflector(clk, reset_n, set, reflector_idx_in, valid4, dout3, dec, dout4, done4);

endmodule

module mux_1(input clk, input S, input[1:0] I, output Out);
    reg Out;
    always @(*) begin
        case(S)
            1'b0: Out <= I[1];
            1'b1: Out <= I[0];
        endcase
    end
endmodule

module mux(input clk, input S, input [15:0] I, output[7:0] Out);
    reg[7:0] Out;
    always @(*) begin
        case(S)
            1'b0: Out <= I[15:8];
            1'b1: Out <= I[7:0];
        endcase
    end
endmodule

module D_FF(input clk, input Q, output reg D);
    always @(posedge clk)
        D <= Q;
endmodule