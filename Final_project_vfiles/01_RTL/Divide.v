


module Divide(i_clk, i_rst, a, b, en, fin, result);
    parameter a_length = 3 + 16 + 8;
    parameter b_length = 3 + 16 + 8;
    input i_clk;
    input i_rst;
    input [a_length-1:0] a; // S1.14
    input [b_length-1:0] b; // 2.14
    input en;
    output fin;
    output [15:0] result;
    reg [1:0] counter_r ,counter_w;
    reg signed [a_length-1:0] temp_a_r, temp_a_w;
    reg [b_length-1:0] temp_b_r, temp_b_w;
    assign result = temp_a_r[23:8];
    assign fin = counter_r == 2'd3;

    always @(*) begin
        counter_w = counter_r;
        if (counter_r == 2'd0) begin
            counter_w = 2'd1;
            if ((|b[23:20])) begin
                if ((|b[23:22])) begin
                    if (b[23]) begin
                        temp_b_w = b >> 2;
                        temp_a_w = a >>> 2;
                    end
                    else if (b[22]) begin
                        temp_b_w = b >> 1;
                        temp_a_w = a >>> 1;
                    end
                end
                else if ((|b[21:20])) begin
                    if (b[21]) begin
                        temp_b_w = b;
                        temp_a_w = a;
                    end
                    else if (b[20]) begin
                        temp_b_w = b << 1;
                        temp_a_w = a << 1;
                    end
                end
            end
            else if ((|b[19:16])) begin
                if ((|b[19:18])) begin
                    if (b[19]) begin
                        temp_b_w = b << 2;
                        temp_a_w = a << 2;
                    end
                    else if (b[18]) begin
                        temp_b_w = b << 3;
                        temp_a_w = a << 3;
                    end
                end
                else if ((|b[17:16])) begin
                    if (b[17]) begin
                        temp_b_w = b << 4;
                        temp_a_w = a << 4;
                    end
                    else if (b[16]) begin
                        temp_b_w = b << 5;
                        temp_a_w = a << 5;
                    end
                end
            end
            else if ((|b[15:12])) begin
                if ((|b[15:14])) begin
                    if (b[15]) begin
                        temp_b_w = b << 6;
                        temp_a_w = a << 6;
                    end
                    else if (b[14]) begin
                        temp_b_w = b << 7;
                        temp_a_w = a << 7;
                    end
                end
                else if ((|b[13:12])) begin
                    if (b[13]) begin
                        temp_b_w = b << 8;
                        temp_a_w = a << 8;
                    end
                    else if (b[12]) begin
                        temp_b_w = b << 9;
                        temp_a_w = a << 9;
                    end
                end
            end
            else if ((|b[11:8])) begin
                if ((|b[11:10])) begin
                    if (b[11]) begin
                        temp_b_w = b << 10;
                        temp_a_w = a << 10;
                    end
                    else if (b[10]) begin
                        temp_b_w = b << 11;
                        temp_a_w = a << 11;
                    end
                end
                else if ((|b[9:8])) begin
                    if (b[9]) begin
                        temp_b_w = b << 12;
                        temp_a_w = a << 12;
                    end
                    else if (b[8]) begin
                        temp_b_w = b << 13;
                        temp_a_w = a << 13;
                    end
                end
            end
        end
        else if (counter_r == 2'd1) begin
            counter_w = 2'd2;
            case (temp_b_r[20:17])
                4'b0000: begin
                    temp_b_w[22:6] = temp_b_r[21:6] + temp_b_r[21:6];
                    temp_a_w[26:6] = temp_a_r[25:6] + temp_a_r[25:6];
                end
                4'b0001: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1) + ((temp_b_r >> 2) + (temp_b_r >> 3));
                    temp_a_w = temp_a_r + (temp_a_r >>> 1) + ((temp_a_r >>> 2) + (temp_a_r >>> 3));
                end
                4'b0010: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1) + ((temp_b_r >> 2) + (temp_b_r >> 4));
                    temp_a_w = temp_a_r + (temp_a_r >>> 1) + ((temp_a_r >>> 2) + (temp_a_r >>> 4));
                end
                4'b0011: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 2);
                    temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 2);
                end
                4'b0100: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 1)) + ((temp_b_r >> 3) + (temp_b_r >> 4));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 1)) + ((temp_a_r >>> 3) + (temp_a_r >>> 4));
                end
                4'b0101: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 3);
                    temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 3);
                end
                4'b0110: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 4);
                    temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 4);                
                end
                4'b0111: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 1);
                    temp_a_w = temp_a_r + (temp_a_r >>> 1);
                end
                4'b1000: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 2)) + ((temp_b_r >> 3) + (temp_b_r >> 4));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 2)) + ((temp_a_r >>> 3) + (temp_a_r >>> 4));
                end
                4'b1001: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 2) + (temp_b_r >> 3);
                    temp_a_w = temp_a_r + (temp_a_r >>> 2) + (temp_a_r >>> 3);
                end
                4'b1010: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 2) + (temp_b_r >> 4);
                    temp_a_w = temp_a_r + (temp_a_r >>> 2) + (temp_a_r >>> 4);
                end
                4'b1011: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 2);
                    temp_a_w = temp_a_r + (temp_a_r >>> 2);
                end
                4'b1100: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 3) + (temp_b_r >> 4);
                    temp_a_w = temp_a_r + (temp_a_r >>> 3) + (temp_a_r >>> 4);
                end
                4'b1101: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 3);
                    temp_a_w = temp_a_r + (temp_a_r >>> 3);
                end
                4'b1110: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 4);
                    temp_a_w = temp_a_r + (temp_a_r >>> 4);
                end
                4'b1111: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 5);
                    temp_a_w = temp_a_r + (temp_a_r >>> 5);
                end
            endcase
        end
        else if (counter_r == 2'd2) begin
            counter_w = 2'd3;
            case (temp_b_r[18:15])
                4'b0000: begin
                    temp_b_w = temp_b_r;
                    temp_a_w = temp_a_r;
                end
                4'b0001: begin
                    temp_b_w = temp_b_r + (temp_b_r >> 8);
                    temp_a_w = temp_a_r + (temp_a_r >>> 8);
                end
                4'b0010: begin
                    temp_b_w = temp_b_r - (temp_b_r >> 6) + (temp_b_r >> 8);
                    temp_a_w = temp_a_r - (temp_a_r >>> 6) + (temp_a_r >>> 8);
                end
                4'b0011: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 6) + (temp_b_r >> 7));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 6) + (temp_a_r >>> 7));
                end
                4'b0100: begin
                    temp_b_w = temp_b_r - (temp_b_r >> 5) + (temp_b_r >> 8);
                    temp_a_w = temp_a_r - (temp_a_r >>> 5) + (temp_a_r >>> 8);
                end
                4'b0101: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 7));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 7));
                end
                4'b0110: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 6));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 6));
                end
                4'b0111: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 6)) - temp_b_r >> 7;
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 6)) - temp_a_r >>> 7;
                end
                4'b1000: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - (temp_b_r >> 4);
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - (temp_a_r >>> 4);
                end
                4'b1001: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 7));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 7));
                end
                4'b1010: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 7));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 7));
                end
                4'b1011: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 6)) - temp_b_r >> 7;
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 6)) - temp_a_r >>> 7;
                end
                4'b1100: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5));
                end
                4'b1101: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - temp_b_r >> 7;
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - temp_a_r >>> 7;
                end
                4'b1110: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - temp_b_r >> 6;
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - temp_a_r >>> 6;
                end
                4'b1111: begin
                    temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - ((temp_b_r >> 6) + (temp_b_r >> 7));
                    temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - ((temp_a_r >>> 6) + (temp_a_r >>> 7));
                end
            endcase
        end
        else begin
            counter_w = 2'd0;
        end 
    end
    

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            counter_r <= 0;
            temp_a_r  <= 0;
            temp_b_r  <= 0;
        end
        else if (en) begin
            counter_r <= counter_w; 
            temp_a_r  <= temp_a_w;
            temp_b_r  <= temp_b_w;
        end
    end
endmodule