module Div_LUT (
    input  [15:0] i_divisor,
    output [15:0] o_reciprocal,
    output [ 3:0] o_shift
);
    reg  [15:0] reciprocal;
    reg  [ 3:0] shift;
    wire [18:0] temp0;
    
    assign o_reciprocal = reciprocal;
    assign o_shift      = shift;
    
    assign temp0 = {i_divisor[13:0], 5'b00000};

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
        case (temp0[18-shift -: 5])
            5'b00000: begin
                reciprocal = 16'b0111111111111111;
            end
            5'b00001: begin
                reciprocal = 16'b0111111000001000;
            end
            5'b00010: begin
                reciprocal = 16'b0111110000011111;
            end
            5'b00011: begin
                reciprocal = 16'b0111101001000101;
            end
            5'b00100: begin
                reciprocal = 16'b0111100001111000;
            end
            5'b00101: begin
                reciprocal = 16'b0111011010111010;
            end
            5'b00110: begin
                reciprocal = 16'b0111010100000111;
            end
            5'b00111: begin
                reciprocal = 16'b0111001101100001;
            end
            5'b01000: begin
                reciprocal = 16'b0111000111000111;
            end
            5'b01001: begin
                reciprocal = 16'b0111000000111000;
            end
            5'b01010: begin
                reciprocal = 16'b0110111010110100;
            end
            5'b01011: begin
                reciprocal = 16'b0110110100111010;
            end
            5'b01100: begin
                reciprocal = 16'b0110101111001010;
            end
            5'b01101: begin
                reciprocal = 16'b0110101001100100;
            end
            5'b01110: begin
                reciprocal = 16'b0110100100000111;
            end
            5'b01111: begin
                reciprocal = 16'b0110011110110010;
            end
            5'b10000: begin
                reciprocal = 16'b0110011001100110;
            end
            5'b10001: begin
                reciprocal = 16'b0110010100100011;
            end
            5'b10010: begin
                reciprocal = 16'b0110001111100111;
            end
            5'b10011: begin
                reciprocal = 16'b0110001010110011;
            end
            5'b10100: begin
                reciprocal = 16'b0110000110000110;
            end
            5'b10101: begin
                reciprocal = 16'b0110000001100000;
            end
            5'b10110: begin
                reciprocal = 16'b0101111101000001;
            end
            5'b10111: begin
                reciprocal = 16'b0101111000101001;
            end
            5'b11000: begin
                reciprocal = 16'b0101110100010111;
            end
            5'b11001: begin
                reciprocal = 16'b0101110000001100;
            end
            5'b11010: begin
                reciprocal = 16'b0101101100000110;
            end
            5'b11011: begin
                reciprocal = 16'b0101101000000110;
            end
            5'b11100: begin
                reciprocal = 16'b0101100100001011;
            end
            5'b11101: begin
                reciprocal = 16'b0101100000010110;
            end
            5'b11110: begin
                reciprocal = 16'b0101011100100110;
            end
            5'b11111: begin
                reciprocal = 16'b0101011000111011;
            end
            default: begin
                reciprocal = 16'b0000000000000000;
            end
        endcase
    end
endmodule
