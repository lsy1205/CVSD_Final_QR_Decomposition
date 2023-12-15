module Div_LUT (
    input  [15:0] i_divisor,
    output [15:0] o_reciprocal,
    output [ 3:0] o_shift
);
    reg  [15:0] reciprocal;
    reg  [ 3:0] shift;
    wire [20:0] temp0;
    
    assign o_reciprocal = reciprocal;
    assign o_shift      = shift;
    
    assign temp0 = {i_divisor[13:0], 7'b0000000};

    always @(*) begin
        shift = 4'd0;
        if (|i_divisor[14:8]) begin
            if (|i_divisor[14:12]) begin
                if (i_divisor[14]) begin
                    shift = 4'd0;
                end
                else if (i_divisor[13]) begin
                    shift = 4'd1;
                end
                else begin
                    shift = 4'd2;
                end
            end
            else if (i_divisor[11]) begin
                shift = 4'd3;
            end
            else begin
                if (i_divisor[10]) begin
                    shift = 4'd4;
                end
                else if (i_divisor[9]) begin
                    shift = 4'd5;
                end
                else begin
                    shift = 4'd6;
                end
            end
        end
        else if (i_divisor[7]) begin
            shift = 4'd7;
        end
        else begin
            if (|i_divisor[6:4]) begin
                if (i_divisor[6]) begin
                    shift = 4'd8;
                end
                else if (i_divisor[5]) begin
                    shift = 4'd9;
                end
                else begin
                    shift = 4'd10;
                end
            end
            else if (i_divisor[3]) begin
                shift = 4'd11;
            end
            else begin
                if (i_divisor[2]) begin
                    shift = 4'd12;
                end
                else if (i_divisor[1]) begin
                    shift = 4'd13;
                end
                else begin
                    shift = 4'd14;
                end
            end
        end
    end

    always @(*) begin
        reciprocal = 16'b0000000000000000;
        case (temp0[20-shift -: 7])
            7'b0000000: begin
                reciprocal = 16'b0111111111111111;
            end
            7'b0000001: begin
                reciprocal = 16'b0111111100000010;
            end
            7'b0000010: begin
                reciprocal = 16'b0111111000001000;
            end
            7'b0000011: begin
                reciprocal = 16'b0111110100010010;
            end
            7'b0000100: begin
                reciprocal = 16'b0111110000011111;
            end
            7'b0000101: begin
                reciprocal = 16'b0111101100110000;
            end
            7'b0000110: begin
                reciprocal = 16'b0111101001000101;
            end
            7'b0000111: begin
                reciprocal = 16'b0111100101011101;
            end
            7'b0001000: begin
                reciprocal = 16'b0111100001111000;
            end
            7'b0001001: begin
                reciprocal = 16'b0111011110010111;
            end
            7'b0001010: begin
                reciprocal = 16'b0111011010111010;
            end
            7'b0001011: begin
                reciprocal = 16'b0111010111011111;
            end
            7'b0001100: begin
                reciprocal = 16'b0111010100000111;
            end
            7'b0001101: begin
                reciprocal = 16'b0111010000110011;
            end
            7'b0001110: begin
                reciprocal = 16'b0111001101100001;
            end
            7'b0001111: begin
                reciprocal = 16'b0111001010010011;
            end
            7'b0010000: begin
                reciprocal = 16'b0111000111000111;
            end
            7'b0010001: begin
                reciprocal = 16'b0111000011111110;
            end
            7'b0010010: begin
                reciprocal = 16'b0111000000111000;
            end
            7'b0010011: begin
                reciprocal = 16'b0110111101110101;
            end
            7'b0010100: begin
                reciprocal = 16'b0110111010110100;
            end
            7'b0010101: begin
                reciprocal = 16'b0110110111110110;
            end
            7'b0010110: begin
                reciprocal = 16'b0110110100111010;
            end
            7'b0010111: begin
                reciprocal = 16'b0110110010000001;
            end
            7'b0011000: begin
                reciprocal = 16'b0110101111001010;
            end
            7'b0011001: begin
                reciprocal = 16'b0110101100010110;
            end
            7'b0011010: begin
                reciprocal = 16'b0110101001100100;
            end
            7'b0011011: begin
                reciprocal = 16'b0110100110110100;
            end
            7'b0011100: begin
                reciprocal = 16'b0110100100000111;
            end
            7'b0011101: begin
                reciprocal = 16'b0110100001011011;
            end
            7'b0011110: begin
                reciprocal = 16'b0110011110110010;
            end
            7'b0011111: begin
                reciprocal = 16'b0110011100001011;
            end
            7'b0100000: begin
                reciprocal = 16'b0110011001100110;
            end
            7'b0100001: begin
                reciprocal = 16'b0110010111000100;
            end
            7'b0100010: begin
                reciprocal = 16'b0110010100100011;
            end
            7'b0100011: begin
                reciprocal = 16'b0110010010000100;
            end
            7'b0100100: begin
                reciprocal = 16'b0110001111100111;
            end
            7'b0100101: begin
                reciprocal = 16'b0110001101001100;
            end
            7'b0100110: begin
                reciprocal = 16'b0110001010110011;
            end
            7'b0100111: begin
                reciprocal = 16'b0110001000011100;
            end
            7'b0101000: begin
                reciprocal = 16'b0110000110000110;
            end
            7'b0101001: begin
                reciprocal = 16'b0110000011110010;
            end
            7'b0101010: begin
                reciprocal = 16'b0110000001100000;
            end
            7'b0101011: begin
                reciprocal = 16'b0101111111010000;
            end
            7'b0101100: begin
                reciprocal = 16'b0101111101000001;
            end
            7'b0101101: begin
                reciprocal = 16'b0101111010110101;
            end
            7'b0101110: begin
                reciprocal = 16'b0101111000101001;
            end
            7'b0101111: begin
                reciprocal = 16'b0101110110011111;
            end
            7'b0110000: begin
                reciprocal = 16'b0101110100010111;
            end
            7'b0110001: begin
                reciprocal = 16'b0101110010010001;
            end
            7'b0110010: begin
                reciprocal = 16'b0101110000001100;
            end
            7'b0110011: begin
                reciprocal = 16'b0101101110001000;
            end
            7'b0110100: begin
                reciprocal = 16'b0101101100000110;
            end
            7'b0110101: begin
                reciprocal = 16'b0101101010000101;
            end
            7'b0110110: begin
                reciprocal = 16'b0101101000000110;
            end
            7'b0110111: begin
                reciprocal = 16'b0101100110001000;
            end
            7'b0111000: begin
                reciprocal = 16'b0101100100001011;
            end
            7'b0111001: begin
                reciprocal = 16'b0101100010010000;
            end
            7'b0111010: begin
                reciprocal = 16'b0101100000010110;
            end
            7'b0111011: begin
                reciprocal = 16'b0101011110011101;
            end
            7'b0111100: begin
                reciprocal = 16'b0101011100100110;
            end
            7'b0111101: begin
                reciprocal = 16'b0101011010110000;
            end
            7'b0111110: begin
                reciprocal = 16'b0101011000111011;
            end
            7'b0111111: begin
                reciprocal = 16'b0101010111001000;
            end
            7'b1000000: begin
                reciprocal = 16'b0101010101010101;
            end
            7'b1000001: begin
                reciprocal = 16'b0101010011100100;
            end
            7'b1000010: begin
                reciprocal = 16'b0101010001110100;
            end
            7'b1000011: begin
                reciprocal = 16'b0101010000000101;
            end
            7'b1000100: begin
                reciprocal = 16'b0101001110011000;
            end
            7'b1000101: begin
                reciprocal = 16'b0101001100101011;
            end
            7'b1000110: begin
                reciprocal = 16'b0101001010111111;
            end
            7'b1000111: begin
                reciprocal = 16'b0101001001010101;
            end
            7'b1001000: begin
                reciprocal = 16'b0101000111101100;
            end
            7'b1001001: begin
                reciprocal = 16'b0101000110000011;
            end
            7'b1001010: begin
                reciprocal = 16'b0101000100011100;
            end
            7'b1001011: begin
                reciprocal = 16'b0101000010110110;
            end
            7'b1001100: begin
                reciprocal = 16'b0101000001010000;
            end
            7'b1001101: begin
                reciprocal = 16'b0100111111101100;
            end
            7'b1001110: begin
                reciprocal = 16'b0100111110001001;
            end
            7'b1001111: begin
                reciprocal = 16'b0100111100100110;
            end
            7'b1010000: begin
                reciprocal = 16'b0100111011000101;
            end
            7'b1010001: begin
                reciprocal = 16'b0100111001100100;
            end
            7'b1010010: begin
                reciprocal = 16'b0100111000000101;
            end
            7'b1010011: begin
                reciprocal = 16'b0100110110100110;
            end
            7'b1010100: begin
                reciprocal = 16'b0100110101001000;
            end
            7'b1010101: begin
                reciprocal = 16'b0100110011101100;
            end
            7'b1010110: begin
                reciprocal = 16'b0100110010010000;
            end
            7'b1010111: begin
                reciprocal = 16'b0100110000110100;
            end
            7'b1011000: begin
                reciprocal = 16'b0100101111011010;
            end
            7'b1011001: begin
                reciprocal = 16'b0100101110000001;
            end
            7'b1011010: begin
                reciprocal = 16'b0100101100101000;
            end
            7'b1011011: begin
                reciprocal = 16'b0100101011010000;
            end
            7'b1011100: begin
                reciprocal = 16'b0100101001111001;
            end
            7'b1011101: begin
                reciprocal = 16'b0100101000100011;
            end
            7'b1011110: begin
                reciprocal = 16'b0100100111001101;
            end
            7'b1011111: begin
                reciprocal = 16'b0100100101111001;
            end
            7'b1100000: begin
                reciprocal = 16'b0100100100100101;
            end
            7'b1100001: begin
                reciprocal = 16'b0100100011010001;
            end
            7'b1100010: begin
                reciprocal = 16'b0100100001111111;
            end
            7'b1100011: begin
                reciprocal = 16'b0100100000101101;
            end
            7'b1100100: begin
                reciprocal = 16'b0100011111011100;
            end
            7'b1100101: begin
                reciprocal = 16'b0100011110001100;
            end
            7'b1100110: begin
                reciprocal = 16'b0100011100111100;
            end
            7'b1100111: begin
                reciprocal = 16'b0100011011101101;
            end
            7'b1101000: begin
                reciprocal = 16'b0100011010011111;
            end
            7'b1101001: begin
                reciprocal = 16'b0100011001010001;
            end
            7'b1101010: begin
                reciprocal = 16'b0100011000000100;
            end
            7'b1101011: begin
                reciprocal = 16'b0100010110111000;
            end
            7'b1101100: begin
                reciprocal = 16'b0100010101101100;
            end
            7'b1101101: begin
                reciprocal = 16'b0100010100100001;
            end
            7'b1101110: begin
                reciprocal = 16'b0100010011010111;
            end
            7'b1101111: begin
                reciprocal = 16'b0100010010001101;
            end
            7'b1110000: begin
                reciprocal = 16'b0100010001000100;
            end
            7'b1110001: begin
                reciprocal = 16'b0100001111111100;
            end
            7'b1110010: begin
                reciprocal = 16'b0100001110110100;
            end
            7'b1110011: begin
                reciprocal = 16'b0100001101101101;
            end
            7'b1110100: begin
                reciprocal = 16'b0100001100100110;
            end
            7'b1110101: begin
                reciprocal = 16'b0100001011100000;
            end
            7'b1110110: begin
                reciprocal = 16'b0100001010011010;
            end
            7'b1110111: begin
                reciprocal = 16'b0100001001010101;
            end
            7'b1111000: begin
                reciprocal = 16'b0100001000010001;
            end
            7'b1111001: begin
                reciprocal = 16'b0100000111001101;
            end
            7'b1111010: begin
                reciprocal = 16'b0100000110001001;
            end
            7'b1111011: begin
                reciprocal = 16'b0100000101000110;
            end
            7'b1111100: begin
                reciprocal = 16'b0100000100000100;
            end
            7'b1111101: begin
                reciprocal = 16'b0100000011000010;
            end
            7'b1111110: begin
                reciprocal = 16'b0100000010000001;
            end
            7'b1111111: begin
                reciprocal = 16'b0100000001000000;
            end
        endcase
    end
endmodule
