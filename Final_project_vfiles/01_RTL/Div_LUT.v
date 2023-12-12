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
        case (temp0[18-shift -: 6])
            6'b000000: begin
                reciprocal = 16'b0111111111111111;
            end
            6'b000001: begin
                reciprocal = 16'b0111111000001000;
            end
            6'b000010: begin
                reciprocal = 16'b0111110000011111;
            end
            6'b000011: begin
                reciprocal = 16'b0111101001000101;
            end
            6'b000100: begin
                reciprocal = 16'b0111100001111000;
            end
            6'b000101: begin
                reciprocal = 16'b0111011010111010;
            end
            6'b000110: begin
                reciprocal = 16'b0111010100000111;
            end
            6'b000111: begin
                reciprocal = 16'b0111001101100001;
            end
            6'b001000: begin
                reciprocal = 16'b0111000111000111;
            end
            6'b001001: begin
                reciprocal = 16'b0111000000111000;
            end
            6'b001010: begin
                reciprocal = 16'b0110111010110100;
            end
            6'b001011: begin
                reciprocal = 16'b0110110100111010;
            end
            6'b001100: begin
                reciprocal = 16'b0110101111001010;
            end
            6'b001101: begin
                reciprocal = 16'b0110101001100100;
            end
            6'b001110: begin
                reciprocal = 16'b0110100100000111;
            end
            6'b001111: begin
                reciprocal = 16'b0110011110110010;
            end
            6'b010000: begin
                reciprocal = 16'b0110011001100110;
            end
            6'b010001: begin
                reciprocal = 16'b0110010100100011;
            end
            6'b010010: begin
                reciprocal = 16'b0110001111100111;
            end
            6'b010011: begin
                reciprocal = 16'b0110001010110011;
            end
            6'b010100: begin
                reciprocal = 16'b0110000110000110;
            end
            6'b010101: begin
                reciprocal = 16'b0110000001100000;
            end
            6'b010110: begin
                reciprocal = 16'b0101111101000001;
            end
            6'b010111: begin
                reciprocal = 16'b0101111000101001;
            end
            6'b011000: begin
                reciprocal = 16'b0101110100010111;
            end
            6'b011001: begin
                reciprocal = 16'b0101110000001100;
            end
            6'b011010: begin
                reciprocal = 16'b0101101100000110;
            end
            6'b011011: begin
                reciprocal = 16'b0101101000000110;
            end
            6'b011100: begin
                reciprocal = 16'b0101100100001011;
            end
            6'b011101: begin
                reciprocal = 16'b0101100000010110;
            end
            6'b011110: begin
                reciprocal = 16'b0101011100100110;
            end
            6'b011111: begin
                reciprocal = 16'b0101011000111011;
            end
            6'b100000: begin
                reciprocal = 16'b0101010101010101;
            end
            6'b100001: begin
                reciprocal = 16'b0101010001110100;
            end
            6'b100010: begin
                reciprocal = 16'b0101001110011000;
            end
            6'b100011: begin
                reciprocal = 16'b0101001010111111;
            end
            6'b100100: begin
                reciprocal = 16'b0101000111101100;
            end
            6'b100101: begin
                reciprocal = 16'b0101000100011100;
            end
            6'b100110: begin
                reciprocal = 16'b0101000001010000;
            end
            6'b100111: begin
                reciprocal = 16'b0100111110001001;
            end
            6'b101000: begin
                reciprocal = 16'b0100111011000101;
            end
            6'b101001: begin
                reciprocal = 16'b0100111000000101;
            end
            6'b101010: begin
                reciprocal = 16'b0100110101001000;
            end
            6'b101011: begin
                reciprocal = 16'b0100110010010000;
            end
            6'b101100: begin
                reciprocal = 16'b0100101111011010;
            end
            6'b101101: begin
                reciprocal = 16'b0100101100101000;
            end
            6'b101110: begin
                reciprocal = 16'b0100101001111001;
            end
            6'b101111: begin
                reciprocal = 16'b0100100111001101;
            end
            6'b110000: begin
                reciprocal = 16'b0100100100100101;
            end
            6'b110001: begin
                reciprocal = 16'b0100100001111111;
            end
            6'b110010: begin
                reciprocal = 16'b0100011111011100;
            end
            6'b110011: begin
                reciprocal = 16'b0100011100111100;
            end
            6'b110100: begin
                reciprocal = 16'b0100011010011111;
            end
            6'b110101: begin
                reciprocal = 16'b0100011000000100;
            end
            6'b110110: begin
                reciprocal = 16'b0100010101101100;
            end
            6'b110111: begin
                reciprocal = 16'b0100010011010111;
            end
            6'b111000: begin
                reciprocal = 16'b0100010001000100;
            end
            6'b111001: begin
                reciprocal = 16'b0100001110110100;
            end
            6'b111010: begin
                reciprocal = 16'b0100001100100110;
            end
            6'b111011: begin
                reciprocal = 16'b0100001010011010;
            end
            6'b111100: begin
                reciprocal = 16'b0100001000010001;
            end
            6'b111101: begin
                reciprocal = 16'b0100000110001001;
            end
            6'b111110: begin
                reciprocal = 16'b0100000100000100;
            end
            6'b111111: begin
                reciprocal = 16'b0100000010000001;
            end
            default: begin
                reciprocal = 16'b0000000000000000;
            end
        endcase
    end
endmodule