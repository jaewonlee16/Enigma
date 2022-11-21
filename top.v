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
    wire dout1, dout2, dout3, dou4;
    wire done1, done2, done3;
    rotor rotor1(clk, reset_n, set, en, valid, rot, din, first_offset, first_delay, first_idx_in, dec, dout1, done1);
    rotor rotor2(clk, reset_n, set, en, done1, rot, dout1, second_offset, second_delay, second_idx_in, dec, dout2, done2);
    rotor rotor3(clk, reset_n, set, en, done2, rot, dout2, third_offset, third_delay, third_idx_in, dec, dout3, done3);
    reflector reflector(clk, reset_n, set, reflector_idx_in, done3, dout3, dec, dout4, done4);
    rotor rotor5(clk, reset_n, set, en, done4, rot, dout4, third_offset, third_delay, third_idx_in, dec, dout5, done5);
    rotor rotor6(clk, reset_n, set, en, done5, rot, dout5, second_offset, second_delay, second_idx_in, dec, dout6, done6);
    rotor rotor7(clk, reset_n, set, en, done6, rot, dout6, first_offset, first_delay, first_idx_in, dec, dout, done);

endmodule
