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
    output reg [7:0] dout,
    output reg done

);

    parameter[1:0] S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
    parameter[1:0] S3 = 2'b00, S4 = 2'b01, S5 = 2'b10;
    reg[1:0] present_state = 2'b00, next_state = 2'b00;
    reg[1:0] dpresent_state = 2'b00, dnext_state = 2'b00;
    reg[7:0] idx_start;
    reg[31:0] count = 0;
    reg old = 1'b0;
    reg[207:0] new_idx_in;
    reg[207:0] calculation_new_idx_in;
 
    reg[7:0] dec_i = 8'b0;
    parameter A = 8'b01000001;
    integer i;
    
    always @(posedge clk) begin
        if(dec == 1'b0) begin 
            if (!reset_n) begin present_state <= S0;  new_idx_in <= 208'b0; dout <= 8'b0; done <= 1'b0; end
            else begin
                present_state = next_state;
                if (en && (present_state == S1 || present_state == S2)) begin
                    for (i = 0; i < offset * 8; i = i + 1) begin
                        old = new_idx_in[207];
                        new_idx_in = new_idx_in << 1;
                        new_idx_in[0] = old;
                    end
                end
            end
            if (en && (present_state == S2)) begin 
                count <= count + 1;
            end
     
        end     
    end

    always @(*) begin
        if(set == 1'b1) begin 
            for (i = 0; i < 208; i = i + 1) begin
                new_idx_in[i] <= idx_in[i];
            end
        end
        if(en) begin
            if(dec == 1'b0) begin
                if(valid) idx_start <= 8'b11001111 - ((din -8'b01000001) << 3);
                case(present_state)
                    S0: begin 
                        count <= 0; 
                        if (valid == 1'b1) next_state = S2;
                        else next_state = S1; 
                    end
                    S1: begin done <= 1'b0; count <= 0; if(valid == 1'b1) begin next_state <= S2; end else next_state <= S1; end
                    S2: if (count == delay - 1) begin 
                            done <= 1'b1; 
                            calculation_new_idx_in = new_idx_in;
                            for (i = 0; i < offset * 8; i = i + 1) begin
                                old = calculation_new_idx_in[207];
                                calculation_new_idx_in = calculation_new_idx_in << 1;
                                calculation_new_idx_in[0] = old;
                            end
                            dout <= calculation_new_idx_in[idx_start -:8]; 
                            next_state = S1; 
                       end 
                       else next_state <= S2;
                endcase
            end    
        end 
    end
    
    always @(posedge clk) begin
        if(dec == 1'b1) begin
            if (!reset_n) present_state <= S0;
            else begin
                dpresent_state = dnext_state;
                if(en && (dpresent_state == S4 || dpresent_state == S5)) begin
                    for (i = 0; i < offset * 8; i = i + 1) begin
                        old = new_idx_in[0];
                        new_idx_in = new_idx_in >> 1;
                        new_idx_in[207] = old;
                    end    
                end
                if(en && (dpresent_state == S4) ) begin
                    count <= count + 1;
                end
            end
        end
    end
    
     always @(*) begin
        if(en) begin
            if(dec == 1'b1) begin
                case(dpresent_state)
                    S3: begin
                        done <= 1'b0;
                        for(i = 0; i < 26; i = i + 1) begin
                            if(new_idx_in[207 - 8*i -:8] == din[7:0])
                            dec_i = i;
                        end
                        dnext_state <= S4;
                    end
                    S4: begin
                        if(count == delay - 1) begin done <= 1'b1; dout <= A + dec_i; dnext_state <= S5; end
                    end
                    S5: begin
                        if(valid) dnext_state <= S3;
                        else dnext_state <= S5;
                        done <= 1'b0;
                        count <= 8'b0;
                    end
                endcase
            end
        
        end
        
     end
     
     always @(posedge dec) begin
        dpresent_state <= S5; 
     end
     
     always @(posedge valid) begin
        dpresent_state <= S3;
     end
     
     always @(negedge dec) begin
        present_state <= S0;
     end
     
endmodule


   

