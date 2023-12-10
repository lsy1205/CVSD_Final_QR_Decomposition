// how to instantiate
// assign temp_a = a[15] ? {3'b111, a} : {3'b000, a};
// Divide ab(
//     .i_clk(i_clk),
//     .i_rst(i_rst),
//     .a(a[15:0]),
//     .b(b[15:0]),
//     .en(1'b1),
//     .fin(div_fin),
//     .result(result[15:0])
// );
module Divide(i_clk, i_rst, a, b, en, fin, result);
    // parameter
    parameter a_length = 3 + 16 + 8;
    parameter b_length = 3 + 16 + 8;

    // IO
    input        i_clk;
    input        i_rst;
    input [15:0] a; // S1.14
    input [15:0] b; // 2.14
    input        en;

    output        fin;
    output [15:0] result;

    // reg and wire
    reg         [         1:0] counter_r ,counter_w;
    reg signed  [a_length-1:0] temp_a_r, temp_a_w;
    reg         [b_length-1:0] temp_b_r, temp_b_w;
    wire signed [a_length-1:0] format_a;
    wire        [b_length-1:0] format_b;

    // adder
    // reg  [a_length-1:0] add0_a, add0_b;
    // wire [a_length-1:0] add0_result;
    // reg  [a_length-1:0] add1_a, add1_b;
    // wire [a_length-1:0] add1_result;
    // reg  [a_length-1:0] add2_a, add2_b;
    // wire [a_length-1:0] add2_result;
    // reg  [a_length-1:0] add3_a, add3_b;
    // wire [a_length-1:0] add3_result;
    // reg  [a_length-1:0] add4_a, add4_b;
    // wire [a_length-1:0] add4_result;
    // reg  [a_length-1:0] add5_a, add5_b;
    // wire [a_length-1:0] add5_result;
    // reg  [a_length-1:0] add6_a, add6_b;
    // wire [a_length-1:0] add6_result;
    // reg  [a_length-1:0] add7_a, add7_b;
    // wire [a_length-1:0] add7_result;
    // reg  [a_length-1:0] add8_a, add8_b;
    // wire [a_length-1:0] add8_result;
    // reg  [a_length-1:0] add9_a, add9_b;
    // wire [a_length-1:0] add9_result;

    // modules
    // adder27 add0(
    //     .a(add0_a),
    //     .b(add0_b),
    //     .result(add0_result)
    // );
    // adder27 add1(
    //     .a(add1_a),
    //     .b(add1_b),
    //     .result(add1_result)
    // );
    // adder27 add2(
    //     .a(add2_a),
    //     .b(add2_b),
    //     .result(add2_result)
    // );
    // adder27 add3(
    //     .a(add3_a),
    //     .b(add3_b),
    //     .result(add3_result)
    // );
    // adder27 add4(
    //     .a(add4_a),
    //     .b(add4_b),
    //     .result(add4_result)
    // );
    // adder27 add5(
    //     .a(add5_a),
    //     .b(add5_b),
    //     .result(add5_result)
    // );
    // adder27 add6(
    //     .a(add6_a),
    //     .b(add6_b),
    //     .result(add6_result)
    // );
    // adder27 add7(
    //     .a(add7_a),
    //     .b(add7_b),
    //     .result(add7_result)
    // );
    // adder27 add8(
    //     .a(add8_a),
    //     .b(add8_b),
    //     .result(add8_result)
    // );
    // adder27 add9(
    //     .a(add9_a),
    //     .b(add9_b),
    //     .result(add9_result)
    // );

    // continuous assignment
    assign format_a = a[15] ? {3'b111, a, 8'b0} : {3'b000, a, 8'b0};
    assign format_b = {3'b0, b, 8'b0};
    assign result   = temp_a_r[23:8];
    assign fin      = counter_r == 2'd3;

    always @(*) begin
        // counter_w = (counter_r == 2'd2) ? 2'd0 : (counter_r + 1'b1);
        counter_w = counter_r + 1'b1;
        temp_a_w  = temp_a_r;
        temp_b_w  = temp_b_r;
        
        // add0_a = {27'b0};
        // add0_b = {27'b0};
        // add1_a = {27'b0};
        // add1_b = {27'b0};
        // add2_a = {27'b0};
        // add2_b = {27'b0};
        // add3_a = {27'b0};
        // add3_b = {27'b0};
        // add4_a = {27'b0};
        // add4_b = {27'b0};
        // add5_a = {27'b0};
        // add5_b = {27'b0};
        // add6_a = {27'b0};
        // add6_b = {27'b0};
        // add7_a = {27'b0};
        // add7_b = {27'b0};
        // add8_a = {27'b0};
        // add8_b = {27'b0};
        // add9_a = {27'b0};
        // add9_b = {27'b0};

        case (counter_r)
            2'd0: begin
                if ((|format_b[23:20])) begin
                    if ((|format_b[23:22])) begin
                        if (format_b[23]) begin
                            temp_b_w = format_b >> 2;
                            temp_a_w = format_a >>> 2;
                        end
                        else if (format_b[22]) begin
                            temp_b_w = format_b >> 1;
                            temp_a_w = format_a >>> 1;
                        end
                    end
                    else if ((|format_b[21:20])) begin
                        if (format_b[21]) begin
                            temp_b_w = format_b;
                            temp_a_w = format_a;
                        end
                        else if (format_b[20]) begin
                            temp_b_w = format_b << 1;
                            temp_a_w = format_a << 1;
                        end
                    end
                end
                else if ((|format_b[19:16])) begin
                    if ((|format_b[19:18])) begin
                        if (format_b[19]) begin
                            temp_b_w = format_b << 2;
                            temp_a_w = format_a << 2;
                        end
                        else if (format_b[18]) begin
                            temp_b_w = format_b << 3;
                            temp_a_w = format_a << 3;
                        end
                    end
                    else if ((|format_b[17:16])) begin
                        if (format_b[17]) begin
                            temp_b_w = format_b << 4;
                            temp_a_w = format_a << 4;
                        end
                        else if (format_b[16]) begin
                            temp_b_w = format_b << 5;
                            temp_a_w = format_a << 5;
                        end
                    end
                end
                else if ((|format_b[15:12])) begin
                    if ((|format_b[15:14])) begin
                        if (format_b[15]) begin
                            temp_b_w = format_b << 6;
                            temp_a_w = format_a << 6;
                        end
                        else if (format_b[14]) begin
                            temp_b_w = format_b << 7;
                            temp_a_w = format_a << 7;
                        end
                    end
                    else if ((|format_b[13:12])) begin
                        if (format_b[13]) begin
                            temp_b_w = format_b << 8;
                            temp_a_w = format_a << 8;
                        end
                        else if (format_b[12]) begin
                            temp_b_w = format_b << 9;
                            temp_a_w = format_a << 9;
                        end
                    end
                end
                else if ((|format_b[11:8])) begin
                    if ((|format_b[11:10])) begin
                        if (format_b[11]) begin
                            temp_b_w = format_b << 10;
                            temp_a_w = format_a << 10;
                        end
                        else if (format_b[10]) begin
                            temp_b_w = format_b << 11;
                            temp_a_w = format_a << 11;
                        end
                    end
                    else if ((|format_b[9:8])) begin
                        if (format_b[9]) begin
                            temp_b_w = format_b << 12;
                            temp_a_w = format_a << 12;
                        end
                        else if (format_b[8]) begin
                            temp_b_w = format_b << 13;
                            temp_a_w = format_a << 13;
                        end
                    end
                end
            end 
            2'd1: begin
                case (temp_b_r[20:17])
                    4'b0000: begin
                        temp_b_w[22:6] = temp_b_r[21:6] + temp_b_r[21:6];
                        temp_a_w[26:6] = temp_a_r[25:6] + temp_a_r[25:6];
                        // add0_a         = temp_b_r   [21:6];
                        // add0_b         = temp_b_r   [21:6];
                        // temp_b_w[22:6] = add0_result[16:0];

                        // add1_a         = temp_a_r   [25:6];
                        // add1_b         = temp_a_r   [25:6];
                        // temp_a_w[26:6] = add1_result[19:0];
                    end
                    4'b0001: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1) + ((temp_b_r >> 2) + (temp_b_r >> 3));
                        temp_a_w = temp_a_r + (temp_a_r >>> 1) + ((temp_a_r >>> 2) + (temp_a_r >>> 3));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 2;
                        // add1_b = temp_b_r >> 3;
                        // add2_a = add0_result;
                        // add2_b = add1_result;
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 1;
                        // add4_a = temp_a_r >>> 2;
                        // add4_b = temp_a_r >>> 3;
                        // add5_a = add3_result;
                        // add5_b = add4_result;
                        // temp_a_w = add5_result;
                    end
                    4'b0010: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1) + ((temp_b_r >> 2) + (temp_b_r >> 4));
                        temp_a_w = temp_a_r + (temp_a_r >>> 1) + ((temp_a_r >>> 2) + (temp_a_r >>> 4));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 2;
                        // add1_b = temp_b_r >> 4;
                        // add2_a = add0_result;
                        // add2_b = add1_result;
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 1;
                        // add4_a = temp_a_r >>> 2;
                        // add4_b = temp_a_r >>> 4;
                        // add5_a = add3_result;
                        // add5_b = add4_result;
                        // temp_a_w = add5_result;
                    end
                    4'b0011: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 2);
                        temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 2);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 2;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 1;
                        // add3_a = temp_a_r >>> 2;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b0100: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 1)) + ((temp_b_r >> 3) + (temp_b_r >> 4));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 1)) + ((temp_a_r >>> 3) + (temp_a_r >>> 4));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 3;
                        // add1_b = temp_b_r >> 4;
                        // add2_a = add0_result;
                        // add2_b = add1_result;
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 1;
                        // add4_a = temp_a_r >>> 3;
                        // add4_b = temp_a_r >>> 4;
                        // add5_a = add3_result;
                        // add5_b = add4_result;
                        // temp_a_w = add5_result;
                    end
                    4'b0101: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 3);
                        temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 3);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 3;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 1;
                        // add3_a = temp_a_r >>> 3;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b0110: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1) + (temp_b_r >> 4);
                        temp_a_w = temp_a_r + (temp_a_r >>> 1) + (temp_a_r >>> 4);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 1;
                        // add3_a = temp_a_r >>> 4;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b0111: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 1);
                        temp_a_w = temp_a_r + (temp_a_r >>> 1);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 1;
                        // temp_b_w = add0_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 1;
                        // temp_a_w = add2_result;
                    end
                    4'b1000: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 2)) + ((temp_b_r >> 3) + (temp_b_r >> 4));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 2)) + ((temp_a_r >>> 3) + (temp_a_r >>> 4));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 2;
                        // add1_a = temp_b_r >> 3;
                        // add1_b = temp_b_r >> 4;
                        // add2_a = add0_result;
                        // add2_b = add1_result;
                        // temp_b_w = add2_result;
                        
                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 2;
                        // add4_a = temp_a_r >>> 3;
                        // add4_b = temp_a_r >>> 4;
                        // add5_a = add3_result;
                        // add5_b = add4_result;
                        // temp_a_w = add5_result;
                    end
                    4'b1001: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 2) + (temp_b_r >> 3);
                        temp_a_w = temp_a_r + (temp_a_r >>> 2) + (temp_a_r >>> 3);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 2;
                        // add1_a = temp_b_r >> 3;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 2;
                        // add3_a = temp_a_r >>> 3;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b1010: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 2) + (temp_b_r >> 4);
                        temp_a_w = temp_a_r + (temp_a_r >>> 2) + (temp_a_r >>> 4);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 2;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 2;
                        // add3_a = temp_a_r >>> 4;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b1011: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 2);
                        temp_a_w = temp_a_r + (temp_a_r >>> 2);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 2;
                        // temp_b_w = add0_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 2;
                        // temp_a_w = add2_result;
                    end
                    4'b1100: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 3) + (temp_b_r >> 4);
                        temp_a_w = temp_a_r + (temp_a_r >>> 3) + (temp_a_r >>> 4);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 3;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 3;
                        // add3_a = temp_a_r >>> 4;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b1101: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 3);
                        temp_a_w = temp_a_r + (temp_a_r >>> 3);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 3;
                        // temp_b_w = add0_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 3;
                        // temp_a_w = add2_result;
                    end
                    4'b1110: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 4);
                        temp_a_w = temp_a_r + (temp_a_r >>> 4);

                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 4;
                        // temp_b_w = add0_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 4;
                        // temp_a_w = add2_result;
                    end
                    4'b1111: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 5);
                        temp_a_w = temp_a_r + (temp_a_r >>> 5);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 5;
                        // temp_b_w = add0_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 5;
                        // temp_a_w = add2_result;
                    end
                endcase
            end
            2'd2: begin
                case (temp_b_r[18:15])
                    4'b0000: begin
                        temp_b_w = temp_b_r;
                        temp_a_w = temp_a_r;
                    end
                    4'b0001: begin
                        temp_b_w = temp_b_r + (temp_b_r >> 8);
                        temp_a_w = temp_a_r + (temp_a_r >>> 8);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // temp_b_w = add0_result;
 
                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 8;
                        // temp_a_w = add2_result;
                    end
                    4'b0010: begin
                        temp_b_w = temp_b_r - (temp_b_r >> 6) + (temp_b_r >> 8);
                        temp_a_w = temp_a_r - (temp_a_r >>> 6) + (temp_a_r >>> 8);
                        // add0_a = temp_b_r;
                        // add0_b = -(temp_b_r >> 6);
                        // add1_a = temp_b_r >> 8;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = -(temp_a_r >>> 6);
                        // add3_a = temp_a_r >>> 8;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b0011: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 6) + (temp_b_r >> 7));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 6) + (temp_a_r >>> 7));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 6;
                        // add1_b = temp_b_r >> 7;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 6;
                        // add4_b = temp_a_r >>> 7;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b0100: begin
                        temp_b_w = temp_b_r - (temp_b_r >> 5) + (temp_b_r >> 8);
                        temp_a_w = temp_a_r - (temp_a_r >>> 5) + (temp_a_r >>> 8);
                        // add0_a = temp_b_r;
                        // add0_b = -(temp_b_r >> 5);
                        // add1_a = temp_b_r >> 8;
                        // add1_b = add0_result;
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = -(temp_a_r >>> 5);
                        // add3_a = temp_a_r >>> 8;
                        // add3_b = add2_result;
                        // temp_a_w = add3_result;
                    end
                    4'b0101: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 7));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 7));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 5;
                        // add1_b = temp_b_r >> 7;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 5;
                        // add4_b = temp_a_r >>> 7;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b0110: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 6));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 6));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 5;
                        // add1_b = temp_b_r >> 6;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 5;
                        // add4_b = temp_a_r >>> 6;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b0111: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 5) + (temp_b_r >> 6)) - temp_b_r >> 7;
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 5) + (temp_a_r >>> 6)) - temp_a_r >>> 7;
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 5;
                        // add1_b = temp_b_r >> 6;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // add3_a = add2_result;
                        // add3_b = -(temp_b_r >> 7);
                        // temp_b_w = add3_result;

                        // add4_a = temp_a_r;
                        // add4_b = temp_a_r >>> 8;
                        // add5_a = temp_a_r >>> 5;
                        // add5_b = temp_a_r >>> 6;
                        // add6_a = add4_result;
                        // add6_b = -(add5_result);
                        // add7_a = add6_result;
                        // add7_b = -(temp_a_r >>> 7);
                        // temp_a_w = add7_result;
                    end
                    4'b1000: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - (temp_b_r >> 4);
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - (temp_a_r >>> 4);
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = add0_result;
                        // add1_b = -(temp_b_r >> 4);
                        // temp_b_w = add1_result;

                        // add2_a = temp_a_r;
                        // add2_b = temp_a_r >>> 8;
                        // add3_a = add2_result;
                        // add3_b = -(temp_a_r >>> 4);
                        // temp_a_w = add3_result;
                    end
                    4'b1001: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 7));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 7));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 7;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 4;
                        // add4_b = temp_a_r >>> 7;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b1010: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 7));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 7));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 7;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 4;
                        // add4_b = temp_a_r >>> 7;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b1011: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 6)) - temp_b_r >> 7;
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 6)) - temp_a_r >>> 7;
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 6;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // add3_a = add2_result;
                        // add3_b = -(temp_b_r >> 7);
                        // temp_b_w = add3_result;

                        // add4_a = temp_a_r;
                        // add4_b = temp_a_r >>> 8;
                        // add5_a = temp_a_r >>> 4;
                        // add5_b = temp_a_r >>> 6;
                        // add6_a = add4_result;
                        // add6_b = -(add5_result);
                        // add7_a = add6_result;
                        // add7_b = -(temp_a_r >>> 7);
                        // temp_a_w = add7_result;
                    end
                    4'b1100: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 5;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // temp_b_w = add2_result;

                        // add3_a = temp_a_r;
                        // add3_b = temp_a_r >>> 8;
                        // add4_a = temp_a_r >>> 4;
                        // add4_b = temp_a_r >>> 5;
                        // add5_a = add3_result;
                        // add5_b = -(add4_result);
                        // temp_a_w = add5_result;
                    end
                    4'b1101: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - temp_b_r >> 7;
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - temp_a_r >>> 7;
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 5;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // add3_a = add2_result;
                        // add3_b = -(temp_b_r >> 7);
                        // temp_b_w = add3_result;

                        // add4_a = temp_a_r;
                        // add4_b = temp_a_r >>> 8;
                        // add5_a = temp_a_r >>> 4;
                        // add5_b = temp_a_r >>> 5;
                        // add6_a = add4_result;
                        // add6_b = -(add5_result);
                        // add7_a = add6_result;
                        // add7_b = -(temp_a_r >>> 7);
                        // temp_a_w = add7_result;
                    end
                    4'b1110: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - temp_b_r >> 6;
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - temp_a_r >>> 6;
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 5;
                        // add2_a = add0_result;
                        // add2_b = -(add1_result);
                        // add3_a = add2_result;
                        // add3_b = -(temp_b_r >> 6);
                        // temp_b_w = add3_result;

                        // add4_a = temp_a_r;
                        // add4_b = temp_a_r >>> 8;
                        // add5_a = temp_a_r >>> 4;
                        // add5_b = temp_a_r >>> 5;
                        // add6_a = add4_result;
                        // add6_b = -(add5_result);
                        // add7_a = add6_result;
                        // add7_b = -(temp_a_r >>> 6);
                        // temp_a_w = add7_result;
                    end
                    4'b1111: begin
                        temp_b_w = (temp_b_r + (temp_b_r >> 8)) - ((temp_b_r >> 4) + (temp_b_r >> 5)) - ((temp_b_r >> 6) + (temp_b_r >> 7));
                        temp_a_w = (temp_a_r + (temp_a_r >>> 8)) - ((temp_a_r >>> 4) + (temp_a_r >>> 5)) - ((temp_a_r >>> 6) + (temp_a_r >>> 7));
                        // add0_a = temp_b_r;
                        // add0_b = temp_b_r >> 8;
                        // add1_a = temp_b_r >> 4;
                        // add1_b = temp_b_r >> 5;
                        // add2_a = temp_b_r >> 6;
                        // add2_b = temp_b_r >> 7;
                        // add3_a = add0_result;
                        // add3_b = -(add1_result);
                        // add4_a = add3_result;
                        // add4_b = -(add2_result);
                        // temp_b_w = add4_result;

                        // add5_a = temp_a_r;
                        // add5_b = temp_a_r >>> 8;
                        // add6_a = temp_a_r >>> 4;
                        // add6_b = temp_a_r >>> 5;
                        // add7_a = temp_a_r >>> 6;
                        // add7_b = temp_a_r >>> 7;
                        // add8_a = add5_result;
                        // add8_b = -(add6_result);
                        // add9_a = add8_result;
                        // add9_b = -(add7_result);
                        // temp_a_w = add9_result;
                    end
                endcase
            end
            2'd3: begin
                
            end
            default: begin
                
            end
        endcase
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

// module adder27 (
//     input  signed [26:0] a,
//     input  signed [26:0] b,
//     output signed [26:0] result
// );
//     assign result = a + b;
// endmodule
