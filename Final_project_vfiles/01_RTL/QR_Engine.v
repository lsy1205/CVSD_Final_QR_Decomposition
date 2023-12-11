module QR_Engine (
    i_clk,
    i_rst,
    i_trig,
    i_data,
    o_rd_vld,
    o_last_data,
    o_y_hat,
    o_r
);

// IO description
input          i_clk;
input          i_rst;
input          i_trig;
input  [ 47:0] i_data;
output         o_rd_vld;
output         o_last_data;
output [159:0] o_y_hat;
output [319:0] o_r;

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
localparam S_IDLE = 2'd0;
localparam S_READ = 2'd1;  // 200 cycles
localparam S_CALC = 2'd2;  // process * 9


// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// IO
reg         rd_vld_w, rd_vld_r;
reg         last_data_w, last_data_r;
reg [39:0] y_hat_w [0:3], y_hat_r [0:3];
reg [319:0] r_w, r_r;

// Control
reg [1:0] state_w, state_r;
reg [7:0] counter_w, counter_r;
reg [3:0] record_w, record_r;
reg [1:0] div_counter_w, div_counter_r;
reg [2:0] sqrt_counter_w, sqrt_counter_r;
reg [2:0] first_proc_counter_w, first_proc_counter_r;
reg [3:0] second_proc_counter_w, second_proc_counter_r;
reg [1:0] mul_iter_w, mul_iter_r;
reg [1:0] sqrt_iter_w, sqrt_iter_r;
reg [4:0] address_counter_w, address_counter_r;

// Memory Blocks
wire [7:0] Q [0:3];  // read data
reg [7:0] A; // input address
reg [7:0] D   [0:3]; // input data
reg       CEN; // chip enable
// reg       WEN [0:3]; // write enable equal i_trig?

// Sqrt Blocks
reg sqrt_en_w, sqrt_en_r;
reg [32:0] sqrt_a;
wire [16:0] sqrt_result;

// Multiply Blocks
reg [15:0]  mul_a1;
reg [15:0]  mul_a2;
reg [15:0]  mul_a3;
reg [15:0]  mul_a4;
reg [15:0]  mul_a5;
reg [15:0]  mul_a6;
reg [15:0]  mul_b1;
reg [15:0]  mul_b2;
reg [15:0]  mul_b3;
reg [15:0]  mul_b4;
reg [15:0]  mul_b5;
reg [15:0]  mul_b6;
wire [31:0] mul_c1;
wire [31:0] mul_c2;
wire [31:0] mul_c3;
wire [31:0] mul_c4;
wire [31:0] mul_c5;
wire [31:0] mul_c6;

// Divide Blocks
reg [15:0] div;
wire [15:0] reciprocal;
wire [3:0] div_shift;

//usual store register
reg [31:0] H_w [0:3][0:3], H_r [0:3][0:3];
reg [31:0] temp_result_w [0:7], temp_result_r [0:7];
reg [3:0] group_number_w, group_number_r;
reg [2:0] col_w, col_r;
reg [1:0] row_w, row_r;
reg [33:0] temp;
reg [33:0] temp2;
reg [32:0] temp3;
reg [32:0] temp4;
reg [32:0] temp5;
reg [32:0] temp6;
reg [32:0] temp7;
reg [32:0] temp8;
reg [32:0] temp9;
reg [32:0] temp10;

// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// IO
assign o_rd_vld    = rd_vld_r;
assign o_last_data = last_data_r;
assign o_y_hat     = {y_hat_r[3], y_hat_r[2], y_hat_r[1], y_hat_r[0]};
assign o_r         = r_r;


// ---------------------------------------------------------------------------
// Macro Instantiate
// ---------------------------------------------------------------------------

// Memory
sram_256x8 mem0(
    .Q(Q[0]),
    .CLK(i_clk),
    .CEN(CEN),
    // .WEN(WEN[0]),
    .WEN(~i_trig),
    .A(A),
    .D(D[0]) // image high 8bit
);

sram_256x8 mem1(
    .Q(Q[1]),
    .CLK(i_clk),
    .CEN(CEN),
    // .WEN(WEN[1]),
    .WEN(~i_trig),
    .A(A),
    .D(D[1]) // image low 8bit
);

sram_256x8 mem2(
    .Q(Q[2]),
    .CLK(i_clk),
    .CEN(CEN),
    // .WEN(WEN[2]),
    .WEN(~i_trig),
    .A(A),
    .D(D[2]) // real high 8bit
);

sram_256x8 mem3(
    .Q(Q[3]),
    .CLK(i_clk),
    .CEN(CEN),
    // .WEN(WEN[3]),
    .WEN(~i_trig),
    .A(A),
    .D(D[3]) // real low 8bit
);

// Division
// Divide div0(
//     .i_clk(i_clk),
//     .i_rst(i_rst),
//     .a(div_a[15:0]), // change name
//     .b(div_b[15:0]), // change name
//     .en(div_en_r),
//     .fin(div_fin), // change name
//     .result(div_result) // change name
// );
Div_LUT div0(
    .i_divisor(div),
    .o_reciprocal(reciprocal),
    .o_shift(div_shift)
);

// Multiplier
Multiplier mul0(
    .A(mul_a1),
    .B(mul_b1),
    .C(mul_c1)
);

Multiplier mul1(
    .A(mul_a2),
    .B(mul_b2),
    .C(mul_c2)
);
Multiplier mul2(
    .A(mul_a3),
    .B(mul_b3),
    .C(mul_c3)
);
Multiplier mul3(
    .A(mul_a4),
    .B(mul_b4),
    .C(mul_c4)
);
Multiplier mul4(
    .A(mul_a5),
    .B(mul_b5),
    .C(mul_c5)
);
Multiplier mul5(
    .A(mul_a6),
    .B(mul_b6),
    .C(mul_c6)
);
// Square Root
DW_sqrt_pipe_inst sqrt(
    .inst_clk(i_clk),
    .inst_rst_n(~i_rst),
    .inst_en(sqrt_en_r),
    .inst_a(sqrt_a),
    .root_inst(sqrt_result)
);

// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
integer i,j;
// Finite State Machine
always @(*) begin
    state_w = state_r;
    case(state_r)
        S_READ: begin
            if (group_number_r == 10) begin
                state_w = S_CALC;
            end
        end
        S_CALC: begin
            if (last_data_r) begin
                state_w = S_READ;
            end
        end
    endcase
end

// Logic
always @(*) begin
    //data IO
    for (i = 0; i < 4; i = i + 1) begin
        y_hat_w[i] = y_hat_r[i];
    end
    r_w = r_r;
    rd_vld_w = 0;
    last_data_w = 0;
    //sram write
    row_w = row_r;
    col_w = col_r;
    counter_w = counter_r;
    //process
    first_proc_counter_w = first_proc_counter_r;
    second_proc_counter_w = second_proc_counter_r;
    group_number_w = group_number_r;
    mul_iter_w = mul_iter_r;
    sqrt_iter_w = sqrt_iter_r;
    //div control
    div_counter_w = div_counter_r;
    div = 0;
    //sqrt control
    sqrt_counter_w = sqrt_counter_r;
    sqrt_en_w = 0;
    sqrt_a = 0;
    //sram read
    address_counter_w = address_counter_r;
    CEN = 1;
    for (i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            H_w[i][j] = H_r[i][j];
        end
    end
    //mul
    mul_a1 = 0;
    mul_a2 = 0;
    mul_a3 = 0;
    mul_a4 = 0;
    mul_a5 = 0;
    mul_a6 = 0;
    mul_b1 = 0;
    mul_b2 = 0;
    mul_b3 = 0;
    mul_b4 = 0;
    mul_b5 = 0;
    mul_b6 = 0;
    //temp store data
    for (i = 0; i < 8; i = i + 1) begin
        temp_result_w[i] = temp_result_r[i];
    end 

    case(state_r)
        S_READ: begin
            if (i_trig) begin
                if (col_r == 4) begin
                    col_w = 0;
                    row_w = row_r + 1;
                    counter_w[7:6] = 2'b11;
                    counter_w[5:2] = group_number_r;
                    counter_w[1:0] = row_r;
                    if (row_r == 3) begin
                        group_number_w = group_number_r + 1;
                    end
                end
                else begin
                    col_w = col_r + 1;
                    counter_w[7:4] = group_number_r;
                    counter_w[3:2] = col_r[1:0];
                    counter_w[1:0] = row_r;
                end

                CEN = 0;
                A = counter_r;
                D[0] = i_data[47:40];
                D[1] = i_data[39:32];
                D[2] = i_data[23:16];
                D[3] = i_data[15:8];

                if (group_number_r == 10) begin
                    counter_w = 0;
                    col_w = 1;
                    group_number_w = 0;
                end
            end
        end
        S_CALC: begin
            if (first_proc_counter_r != 7) begin
                first_proc_counter_w = first_proc_counter_r + 1;
            end
            if (second_proc_counter_r != 0) begin
                second_proc_counter_w = second_proc_counter_r + 1;
            end
            // reset signal
            if (rd_vld_r == 1) begin
                address_counter_w = 0;
                first_proc_counter_w = 0;
                group_number_w = group_number_r + 1;
            end
            if (last_data_r) begin
                group_number_w = 0;
            end
            // end reset signal

            // Sram access
            if (address_counter_r != 20) begin
                if (first_proc_counter_r != 0) begin
                    address_counter_w = address_counter_r + 1;
                    if (address_counter_r[4]) begin
                        y_hat_w[address_counter_r[1:0]] = {Q[0],Q[1],Q[2],Q[3]};
                        A = {2'b11, group_number_r, address_counter_w[1:0]};
                    end    
                    else begin
                        H_w[address_counter_r[1:0]][address_counter_r[3:2]] = {Q[0],Q[1],Q[2],Q[3]};
                        A = {group_number_r, address_counter_w[3:0]};
                    end
                end 
                else begin
                    A = {group_number_r, 4'b0};
                end
                CEN = 0;
            end
            // end Sram access

            // sqrt control
            if (sqrt_counter_r != 0 && sqrt_counter_r != 4) begin
                sqrt_en_w = 1;
                sqrt_counter_w = sqrt_counter_r + 1;
            end
            if (sqrt_counter_r == 4) begin
                sqrt_counter_w = 0;
                div_counter_w = 1;
            end
            if (sqrt_counter_r == 1) begin
                sqrt_a = {1'b0, temp_result_r[6]};
            end
            // end sqrt control

            // divide control
            if (div_counter_r == 1) begin
                //different iteration is different
                if (sqrt_iter_r == 0) begin
                    r_w[19:2] = {1'b0,sqrt_result};
                    sqrt_iter_w = 1;
                end
                else if (sqrt_iter_r == 1) begin
                    r_w[79:62] = {1'b0,sqrt_result};
                    sqrt_iter_w = 2;
                end
                else if (sqrt_iter_r == 2) begin
                    r_w[179:162] = {1'b0,sqrt_result};
                    sqrt_iter_w = 3;
                end
                else if (sqrt_iter_r == 3) begin
                    r_w[319:302] = {1'b0,sqrt_result};
                    sqrt_iter_w = 0;
                end
                div = sqrt_result[15:0];
                temp_result_w[0] = reciprocal;
                temp_result_w[1] = div_shift;
            end
            if (div_counter_r != 0) begin
                div_counter_w = div_counter_r + 1;
            end
            if (div_counter_r == 2) begin
                mul_a1 = H_r[0][0][31:16];
                mul_b1 = temp_result_r[0][15:0];
                temp[30:0] = mul_c1[30:0] << (temp_result_r[1]);
                H_w[0][0][31:16] = {mul_c1[31], temp[29:15]};
                mul_a2 = H_r[0][0][15:0];
                mul_b2 = temp_result_r[0][15:0];
                temp2[30:0] = mul_c2[30:0] << temp_result_r[1];
                H_w[0][0][15:0] = {mul_c2[31], temp2[29:15]};
                mul_a3 = H_r[1][0][31:16];
                mul_b3 = temp_result_r[0][15:0];
                temp3[30:0] = mul_c3[30:0] << temp_result_r[1];
                H_w[1][0][31:16] = {mul_c3[31], temp3[29:15]};
                mul_a4 = H_r[1][0][15:0];
                mul_b4 = temp_result_r[0][15:0];
                temp4[30:0] = mul_c4[30:0] << temp_result_r[1];
                H_w[1][0][15:0] = {mul_c4[31], temp4[29:15]};
            end
            if (div_counter_r == 3) begin
                div_counter_w = 0;
                second_proc_counter_w = 1;

                mul_a1 = H_r[2][0][31:16];
                mul_b1 = temp_result_r[0][15:0];
                temp[30:0] = mul_c1[30:0] << temp_result_r[1];
                H_w[2][0][31:16] = {mul_c1[31], temp[29:15]};
                mul_a2 = H_r[2][0][15:0];
                mul_b2 = temp_result_r[0][15:0];
                temp2[30:0] = mul_c2[30:0] << temp_result_r[1];
                H_w[2][0][15:0] = {mul_c2[31], temp2[29:15]};
                mul_a3 = H_r[3][0][31:16];
                mul_b3 = temp_result_r[0][15:0];
                temp3[30:0] = mul_c3[30:0] << temp_result_r[1];
                H_w[3][0][31:16] = {mul_c3[31], temp3[29:15]};
                mul_a4 = H_r[3][0][15:0];
                mul_b4 = temp_result_r[0][15:0];
                temp4[30:0] = mul_c4[30:0] << temp_result_r[1];
                H_w[3][0][15:0] = {mul_c4[31], temp4[29:15]};
            end
            // multipliers folding and main logic
            case (first_proc_counter_r)
                3'd2: begin
                    mul_a1 = H_r[0][0][31:16];
                    mul_b1 = H_r[0][0][31:16];
                    mul_a2 = H_r[0][0][15:0];
                    mul_b2 = H_r[0][0][15:0];
                    temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                end
                3'd3: begin
                    mul_a1 = H_r[1][0][31:16];
                    mul_b1 = H_r[1][0][31:16];
                    mul_a2 = H_r[1][0][15:0];
                    mul_b2 = H_r[1][0][15:0];
                    temp_result_w[1] = mul_c1[30:0] + mul_c2[30:0];
                end
                3'd4: begin
                    mul_a1 = H_r[2][0][31:16];
                    mul_b1 = H_r[2][0][31:16];
                    mul_a2 = H_r[2][0][15:0];
                    mul_b2 = H_r[2][0][15:0];
                    temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                end
                3'd5: begin
                    mul_a1 = H_r[3][0][31:16];
                    mul_b1 = H_r[3][0][31:16];
                    mul_a2 = H_r[3][0][15:0];
                    mul_b2 = H_r[3][0][15:0];
                    temp_result_w[3] = mul_c1[30:0] + mul_c2[30:0];
                end
                3'd6: begin
                    temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                    temp_result_w[6] = temp[31:0];
                    sqrt_en_w = 1;
                    sqrt_counter_w = 1;
                end
            endcase
            
            // complex inner product
            // r = c(a-b) + b(c+d)
            // i = c(a-b) + a(d-c)
            if (mul_iter_r == 0) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        // a = H_r[0][0][15:0]  b = H_r[0][0][31:16]  c = H_r[0][1][15:0]  d = H_r[0][1][31:16]

                        mul_a1 = $signed(H_r[0][0][15:0]) - $signed(H_r[0][0][31:16]); //Q11 = H11 
                        mul_b1 = H_r[0][1][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][1][15:0]) + $signed(H_r[0][1][31:16]);
                        mul_b2 = H_r[0][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][1][31:16]) - $signed(H_r[0][1][15:0]);
                        mul_b3 = H_r[0][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][0][15:0]  b = H_r[1][0][31:16]  c = H_r[1][1][15:0]  d = H_r[1][1][31:16]
                        mul_a4 = $signed(H_r[1][0][15:0]) - $signed(H_r[1][0][31:16]); //Q21 = H21 
                        mul_b4 = H_r[1][1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][1][15:0]) + $signed(H_r[1][1][31:16]);
                        mul_b5 = H_r[1][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][1][31:16]) - $signed(H_r[1][1][15:0]);
                        mul_b6 = H_r[1][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd2: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][0][15:0]  b = H_r[2][0][31:16]  c = H_r[2][1][15:0]  d = H_r[2][1][31:16]
                        mul_a1 = $signed(H_r[2][0][15:0]) - $signed(H_r[2][0][31:16]); //Q31 = H31
                        mul_b1 = H_r[2][1][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][1][15:0]) + $signed(H_r[2][1][31:16]);
                        mul_b2 = H_r[2][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][1][31:16]) - $signed(H_r[2][1][15:0]);
                        mul_b3 = H_r[2][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][0][15:0]  b = H_r[3][0][31:16]  c = H_r[3][1][15:0]  d = H_r[3][1][31:16]
                        mul_a4 = $signed(H_r[3][0][15:0]) - $signed(H_r[3][0][31:16]); //Q41 = H41
                        mul_b4 = H_r[3][1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][1][15:0]) + $signed(H_r[3][1][31:16]);
                        mul_b5 = H_r[3][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][1][31:16]) - $signed(H_r[3][1][15:0]);
                        mul_b6 = H_r[3][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd3: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[59:40] = {temp2[33],temp2[30:12]}; // R12
                        r_w[39:20] = {temp[33],temp[30:12]};

                        // a = H_r[0][0][15:0]  b = H_r[0][0][31:16]  c = H_r[0][2][15:0]  d = H_r[0][2][31:16]
                        mul_a1 = $signed(H_r[0][0][15:0]) - $signed(H_r[0][0][31:16]); //Q11 = H11 
                        mul_b1 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][2][15:0]) + $signed(H_r[0][2][31:16]);
                        mul_b2 = H_r[0][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][2][31:16]) - $signed(H_r[0][2][15:0]);
                        mul_b3 = H_r[0][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][0][15:0]  b = H_r[1][0][31:16]  c = H_r[1][2][15:0]  d = H_r[1][2][31:16]
                        mul_a4 = $signed(H_r[1][0][15:0]) - $signed(H_r[1][0][31:16]); //Q21 = H21
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][2][15:0]) + $signed(H_r[1][2][31:16]);
                        mul_b5 = H_r[1][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][2][31:16]) - $signed(H_r[1][2][15:0]);
                        mul_b6 = H_r[1][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd4: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][0][15:0]  b = H_r[2][0][31:16]  c = H_r[2][2][15:0]  d = H_r[2][2][31:16]
                        mul_a1 = $signed(H_r[2][0][15:0]) - $signed(H_r[2][0][31:16]); //Q31 = H31
                        mul_b1 = H_r[2][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][2][15:0]) + $signed(H_r[2][2][31:16]);
                        mul_b2 = H_r[2][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][2][31:16]) - $signed(H_r[2][2][15:0]);
                        mul_b3 = H_r[2][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][0][15:0]  b = H_r[3][0][31:16]  c = H_r[3][2][15:0]  d = H_r[3][2][31:16]
                        mul_a4 = $signed(H_r[3][0][15:0]) - $signed(H_r[3][0][31:16]); //Q41 = H41
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = H_r[3][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = H_r[3][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd5: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[119:100] = {temp2[33],temp2[30:12]}; // R13
                        r_w[99:80] = {temp[33],temp[30:12]};

                        // a = H_r[0][0][15:0]  b = H_r[0][0][31:16]  c = H_r[0][3][15:0]  d = H_r[0][3][31:16]
                        mul_a1 = $signed(H_r[0][0][15:0]) - $signed(H_r[0][0][31:16]); //Q11 = H11 
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = H_r[0][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = H_r[0][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][0][15:0]  b = H_r[1][0][31:16]  c = H_r[1][3][15:0]  d = H_r[1][3][31:16]
                        mul_a4 = $signed(H_r[1][0][15:0]) - $signed(H_r[1][0][31:16]); //Q21 = H21
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = H_r[1][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = H_r[1][0][15:0];
                        temp_result_w[5] = mul_c6;

                    end
                    4'd6: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][0][15:0]  b = H_r[2][0][31:16]  c = H_r[2][3][15:0]  d = H_r[2][3][31:16]
                        mul_a1 = $signed(H_r[2][0][15:0]) - $signed(H_r[2][0][31:16]); //Q31 = H31
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = H_r[2][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = H_r[2][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][0][15:0]  b = H_r[3][0][31:16]  c = H_r[3][3][15:0]  d = H_r[3][3][31:16]
                        mul_a4 = $signed(H_r[3][0][15:0]) - $signed(H_r[3][0][31:16]); //Q41 = H41
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = H_r[3][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = H_r[3][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd7: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[219:200] = {temp2[33],temp2[30:12]}; //R14
                        r_w[199:180] = {temp[33],temp[30:12]};

/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////
/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////
/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////
/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////
/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////
/////////////     should change projection mul_b to "e" and revise mul_a to temp !!!!! ///////////////


                        // r = c(a+b) - b(c+d)
                        // i = c(a+b) + a(d-c)
                        // a = r_r[39:20]  b = r_r[59:40]  c = H_r[0][1][15:0]  d = H_r[0][1][31:16]
                        temp[20:0] = $signed(r_r[39:20]) + $signed(r_r[59:40]); 
                        mul_a1 = {temp[20], temp[2 +: 15]}; // R12 * e1
                        mul_b1 = H_r[0][0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][0][15:0]) + $signed(H_r[0][0][31:16]);
                        mul_b2 = {r_r[59], r_r[42+:15]};
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][0][31:16]) - $signed(H_r[0][0][15:0]);
                        mul_b3 = {r_r[39], r_r[22+:15]};
                        temp_result_w[2] = mul_c3;

                        mul_a4 = {temp[20], temp[2 +: 15]};
                        mul_b4 = H_r[1][0][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][0][15:0]) + $signed(H_r[1][0][31:16]);
                        mul_b5 = {r_r[59], r_r[42+:15]};
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][0][31:16]) - $signed(H_r[1][0][15:0]);
                        mul_b6 = {r_r[39], r_r[22+:15]};
                        temp_result_w[5] = mul_c6;
                    end
                    4'd8: begin
                        H_w[0][1][15:0] = $signed(H_r[0][1][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][1][31:16] = $signed(H_r[0][1][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][1][15:0] = $signed(H_r[1][1][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][1][31:16] = $signed(H_r[1][1][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        temp[20:0] = $signed(r_r[39:20]) + $signed(r_r[59:40]); 
                        mul_a1 = {temp[20], temp[2 +: 15]}; // R12
                        mul_b1 = H_r[2][0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][0][15:0]) + $signed(H_r[2][0][31:16]);
                        mul_b2 = {r_r[59], r_r[42+:15]};
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][0][31:16]) - $signed(H_r[2][0][15:0]);
                        mul_b3 = {r_r[39], r_r[22+:15]};
                        temp_result_w[2] = mul_c3;

                        mul_a4 = {temp[20], temp[2 +: 15]};
                        mul_b4 = H_r[3][0][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][0][15:0]) + $signed(H_r[3][0][31:16]);
                        mul_b5 = {r_r[59], r_r[42+:15]};
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][0][31:16]) - $signed(H_r[3][0][15:0]);
                        mul_b6 = {r_r[39], r_r[22+:15]};
                        temp_result_w[5] = mul_c6;
                    end
                    4'd9: begin
                        H_w[2][1][15:0] = $signed(H_r[2][1][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][1][31:16] = $signed(H_r[2][1][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][1][15:0] = $signed(H_r[3][1][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][1][31:16] = $signed(H_r[3][1][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});
                        
                        mul_a1 = H_r[0][1][31:16];
                        mul_b1 = H_r[0][1][31:16];
                        mul_a2 = H_r[0][1][15:0];
                        mul_b2 = H_r[0][1][15:0];
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[1][1][31:16];
                        mul_b3 = H_r[1][1][31:16];
                        mul_a4 = H_r[1][1][15:0];
                        mul_b4 = H_r[1][1][15:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd10: begin
                        mul_a1 = H_r[2][1][31:16];
                        mul_b1 = H_r[2][1][31:16];
                        mul_a2 = H_r[2][1][15:0];
                        mul_b2 = H_r[2][1][15:0];
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[3][1][31:16];
                        mul_b3 = H_r[3][1][31:16];
                        mul_a4 = H_r[3][1][15:0];
                        mul_b4 = H_r[3][1][15:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd11: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;
                    
                        mul_a1 = $signed(r_r[99:80]) + $signed(r_r[119:100]); // R13
                        mul_b1 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][2][15:0]) + $signed(H_r[0][2][31:16]);
                        mul_b2 = r_r[119:100];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][2][31:16]) - $signed(H_r[0][2][15:0]);
                        mul_b3 = r_r[99:80];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[99:80]) + $signed(r_r[119:100]);
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][2][15:0]) + $signed(H_r[1][2][31:16]);
                        mul_b5 = r_r[119:100];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][2][31:16]) - $signed(H_r[1][2][15:0]);
                        mul_b6 = r_r[99:80];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd12: begin
                        H_w[0][2][15:0] = $signed(H_r[0][2][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][2][31:16] = $signed(H_r[0][2][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][2][15:0] = $signed(H_r[1][2][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][2][31:16] = $signed(H_r[1][2][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[99:80]) + $signed(r_r[119:100]); // R13
                        mul_b1 = H_r[2][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][2][15:0]) + $signed(H_r[2][2][31:16]);
                        mul_b2 = r_r[119:100];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][2][31:16]) - $signed(H_r[2][2][15:0]);
                        mul_b3 = r_r[99:80];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[99:80]) + $signed(r_r[119:100]);
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = r_r[119:100];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = r_r[99:80];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd13: begin
                        H_w[2][2][15:0] = $signed(H_r[2][2][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][2][31:16] = $signed(H_r[2][2][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][2][15:0] = $signed(H_r[3][2][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][2][31:16] = $signed(H_r[3][2][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[199:180]) + $signed(r_r[219:200]); // R14
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = r_r[219:200];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = r_r[199:180];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[199:180]) + $signed(r_r[219:200]);
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = r_r[219:200];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = r_r[199:180];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd14: begin
                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[199:180]) + $signed(r_r[219:200]); // R14
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = r_r[219:200];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = r_r[199:180];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[199:180]) + $signed(r_r[219:200]);
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = r_r[219:200];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = r_r[199:180];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd15: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                endcase
            end
            if (mul_iter_r == 1) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        // a = H_r[0][1][15:0]  b = H_r[0][1][31:16]  c = H_r[0][2][15:0]  d = H_r[0][2][31:16]
                        mul_a1 = $signed(H_r[0][1][15:0]) - $signed(H_r[0][1][31:16]); 
                        mul_b1 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][2][15:0]) + $signed(H_r[0][2][31:16]);
                        mul_b2 = H_r[0][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][2][31:16]) - $signed(H_r[0][2][15:0]);
                        mul_b3 = H_r[0][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][1][15:0]  b = H_r[1][1][31:16]  c = H_r[1][2][15:0]  d = H_r[1][2][31:16]
                        mul_a4 = $signed(H_r[1][1][15:0]) - $signed(H_r[1][1][31:16]); 
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][2][15:0]) + $signed(H_r[1][2][31:16]);
                        mul_b5 = H_r[1][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][2][31:16]) - $signed(H_r[1][2][15:0]);
                        mul_b6 = H_r[1][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd2: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][1][15:0]  b = H_r[2][1][31:16]  c = H_r[2][2][15:0]  d = H_r[2][2][31:16]
                        mul_a1 = $signed(H_r[2][1][15:0]) - $signed(H_r[2][1][31:16]); 
                        mul_b1 = H_r[2][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][2][15:0]) + $signed(H_r[2][2][31:16]);
                        mul_b2 = H_r[2][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][2][31:16]) - $signed(H_r[2][2][15:0]);
                        mul_b3 = H_r[2][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][1][15:0]  b = H_r[3][1][31:16]  c = H_r[3][2][15:0]  d = H_r[3][2][31:16]
                        mul_a4 = $signed(H_r[3][1][15:0]) - $signed(H_r[3][1][31:16]); 
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = H_r[3][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = H_r[3][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd3: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[159:140] = {temp2[33],temp2[30:12]}; // R23
                        r_w[139:120] = {temp[33],temp[30:12]};

                        // a = H_r[0][1][15:0]  b = H_r[0][1][31:16]  c = H_r[0][3][15:0]  d = H_r[0][3][31:16]
                        mul_a1 = $signed(H_r[0][1][15:0]) - $signed(H_r[0][1][31:16]); 
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = H_r[0][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = H_r[0][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][1][15:0]  b = H_r[1][1][31:16]  c = H_r[1][3][15:0]  d = H_r[1][3][31:16]
                        mul_a4 = $signed(H_r[1][1][15:0]) - $signed(H_r[1][1][31:16]); 
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = H_r[1][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = H_r[1][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd4: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][1][15:0]  b = H_r[2][1][31:16]  c = H_r[2][3][15:0]  d = H_r[2][3][31:16]
                        mul_a1 = $signed(H_r[2][1][15:0]) - $signed(H_r[2][1][31:16]); 
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = H_r[2][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = H_r[2][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][1][15:0]  b = H_r[3][1][31:16]  c = H_r[3][3][15:0]  d = H_r[3][3][31:16]
                        mul_a4 = $signed(H_r[2][1][15:0]) - $signed(H_r[3][1][31:16]); 
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = H_r[3][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = H_r[3][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd5: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[259:240] = {temp2[33],temp2[30:12]}; // R24
                        r_w[239:220] = {temp[33],temp[30:12]};

                        mul_a1 = $signed(r_r[139:120]) + $signed(r_r[159:140]); // R23
                        mul_b1 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][2][15:0]) + $signed(H_r[0][2][31:16]);
                        mul_b2 = r_r[159:140];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][2][31:16]) - $signed(H_r[0][2][15:0]);
                        mul_b3 = r_r[139:120];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[139:120]) + $signed(r_r[159:140]);
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][2][15:0]) + $signed(H_r[1][2][31:16]);
                        mul_b5 = r_r[159:140];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][2][31:16]) - $signed(H_r[1][2][15:0]);
                        mul_b6 = r_r[139:120];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd6: begin
                        H_w[0][2][15:0] = $signed(H_r[0][2][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][2][31:16] = $signed(H_r[0][2][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][2][15:0] = $signed(H_r[1][2][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][2][31:16] = $signed(H_r[1][2][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[139:120]) + $signed(r_r[159:140]); // R23
                        mul_b1 = H_r[2][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][2][15:0]) + $signed(H_r[2][2][31:16]);
                        mul_b2 = r_r[159:140];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][2][31:16]) - $signed(H_r[2][2][15:0]);
                        mul_b3 = r_r[139:120];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[139:120]) + $signed(r_r[159:140]);
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = r_r[159:140];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = r_r[139:120];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd7: begin
                        H_w[2][2][15:0] = $signed(H_r[2][2][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][2][31:16] = $signed(H_r[2][2][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][2][15:0] = $signed(H_r[3][2][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][2][31:16] = $signed(H_r[3][2][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});
                        
                        mul_a1 = H_r[0][2][31:16];
                        mul_b1 = H_r[0][2][31:16];
                        mul_a2 = H_r[0][2][15:0];
                        mul_b2 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[1][2][31:16];
                        mul_b3 = H_r[1][2][31:16];
                        mul_a4 = H_r[1][2][15:0];
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd8: begin
                        mul_a1 = H_r[2][2][31:16];
                        mul_b1 = H_r[2][2][31:16];
                        mul_a2 = H_r[2][2][15:0];
                        mul_b2 = H_r[2][2][15:0];
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[3][2][31:16];
                        mul_b3 = H_r[3][2][31:16];
                        mul_a4 = H_r[3][2][15:0];
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd9: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;
                    
                        mul_a1 = $signed(r_r[239:220]) + $signed(r_r[259:240]); // R24
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = r_r[259:240];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = r_r[239:220];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[239:220]) + $signed(r_r[259:240]);
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = r_r[259:240];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = r_r[239:220];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd10: begin
                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[239:220]) + $signed(r_r[259:240]); // R24
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = r_r[259:240];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = r_r[239:220];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[239:220]) + $signed(r_r[259:240]);
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = r_r[259:240];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = r_r[239:220];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd11: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                endcase
            end
            if (mul_iter_r == 2) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        // a = H_r[0][2][15:0]  b = H_r[0][2][31:16]  c = H_r[0][3][15:0]  d = H_r[0][3][31:16]
                        mul_a1 = $signed(H_r[0][2][15:0]) - $signed(H_r[0][2][31:16]); 
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = H_r[0][2][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = H_r[0][2][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][2][15:0]  b = H_r[1][2][31:16]  c = H_r[1][3][15:0]  d = H_r[1][3][31:16]
                        mul_a4 = $signed(H_r[1][2][15:0]) - $signed(H_r[1][2][31:16]); 
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = H_r[1][2][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = H_r[1][2][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd2: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][2][15:0]  b = H_r[2][2][31:16]  c = H_r[2][3][15:0]  d = H_r[2][3][31:16]
                        mul_a1 = $signed(H_r[2][2][15:0]) - $signed(H_r[2][2][31:16]); 
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = H_r[2][2][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = H_r[2][2][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][2][15:0]  b = H_r[3][2][31:16]  c = H_r[3][2][15:0]  d = H_r[3][2][31:16]
                        mul_a4 = $signed(H_r[3][2][15:0]) - $signed(H_r[3][2][31:16]); 
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = H_r[3][2][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = H_r[3][2][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd3: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[299:280] = {temp2[33],temp2[30:12]}; // R34
                        r_w[279:260] = {temp[33],temp[30:12]};
                    end
                    4'd4: begin
                        mul_a1 = $signed(r_r[279:260]) + $signed(r_r[299:280]); // R34
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = r_r[299:280];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = r_r[279:260];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[279:260]) + $signed(r_r[299:280]);
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = r_r[299:280];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = r_r[279:260];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd5: begin
                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = $signed(r_r[279:260]) + $signed(r_r[299:280]); // R34
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = r_r[299:280];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = r_r[279:260];
                        temp_result_w[2] = mul_c3;

                        mul_a4 = $signed(r_r[279:260]) + $signed(r_r[299:280]);
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = r_r[299:280];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = r_r[279:260];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd6: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) + $signed({temp_result_r[1][31], temp_result_r[1][14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({temp_result_r[0][31], temp_result_r[0][14+:15]}) - $signed({temp_result_r[2][31], temp_result_r[2][14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) + $signed({temp_result_r[4][31], temp_result_r[4][14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({temp_result_r[3][31], temp_result_r[3][14+:15]}) - $signed({temp_result_r[5][31], temp_result_r[5][14+:15]});

                        mul_a1 = H_r[0][3][31:16];
                        mul_b1 = H_r[0][3][31:16];
                        mul_a2 = H_r[0][3][15:0];
                        mul_b2 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[1][3][31:16];
                        mul_b3 = H_r[1][3][31:16];
                        mul_a4 = H_r[1][3][15:0];
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd7: begin
                        mul_a1 = H_r[2][3][31:16];
                        mul_b1 = H_r[2][3][31:16];
                        mul_a2 = H_r[2][3][15:0];
                        mul_b2 = H_r[2][3][15:0];
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        mul_a3 = H_r[3][3][31:16];
                        mul_b3 = H_r[3][3][31:16];
                        mul_a4 = H_r[3][3][15:0];
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd8: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                endcase
            end
            if (mul_iter_r == 3) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        // a = H_r[0][0][15:0]  b = H_r[0][0][31:16]  c = y_hat_r[0][15:0]  d = y_hat_r[0][31:16]
                        mul_a1 = $signed(H_r[0][0][15:0]) - $signed(H_r[0][0][31:16]); 
                        mul_b1 = y_hat_r[0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[0][15:0]) + $signed(y_hat_r[0][31:16]);
                        mul_b2 = H_r[0][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[0][31:16]) - $signed(y_hat_r[0][15:0]);
                        mul_b3 = H_r[0][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][0][15:0]  b = H_r[1][0][31:16]  c = y_hat_r[1][15:0]  d = y_hat_r[1][31:16]
                        mul_a4 = $signed(H_r[1][0][15:0]) - $signed(H_r[1][0][31:16]); 
                        mul_b4 = y_hat_r[1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[1][15:0]) + $signed(y_hat_r[1][31:16]);
                        mul_b5 = H_r[1][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[1][31:16]) - $signed(y_hat_r[1][15:0]);
                        mul_b6 = H_r[1][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd2: begin
                        H_w[0][0] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[1][0] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][0][15:0]  b = H_r[2][0][31:16]  c = y_hat_r[2][15:0]  d = y_hat_r[2][31:16]
                        mul_a1 = $signed(H_r[2][0][15:0]) - $signed(H_r[2][0][31:16]); 
                        mul_b1 = y_hat_r[2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[2][15:0]) + $signed(y_hat_r[2][31:16]);
                        mul_b2 = H_r[2][0][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[2][31:16]) - $signed(y_hat_r[2][15:0]);
                        mul_b3 = H_r[2][0][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][0][15:0]  b = H_r[3][0][31:16]  c = y_hat_r[3][15:0]  d = y_hat_r[3][31:16]
                        mul_a4 = $signed(H_r[3][0][15:0]) - $signed(H_r[3][0][31:16]); 
                        mul_b4 = y_hat_r[3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[3][15:0]) + $signed(y_hat_r[3][31:16]);
                        mul_b5 = H_r[3][0][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[3][31:16]) - $signed(y_hat_r[3][15:0]);
                        mul_b6 = H_r[3][0][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd3: begin
                        H_w[2][0] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[3][0] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[0][1][15:0]  b = H_r[0][1][31:16]  c = y_hat_r[0][15:0]  d = y_hat_r[0][31:16]
                        mul_a1 = $signed(H_r[0][1][15:0]) - $signed(H_r[0][1][31:16]); 
                        mul_b1 = y_hat_r[0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[0][15:0]) + $signed(y_hat_r[0][31:16]);
                        mul_b2 = H_r[0][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[0][31:16]) - $signed(y_hat_r[0][15:0]);
                        mul_b3 = H_r[0][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][1][15:0]  b = H_r[1][1][31:16]  c = y_hat_r[1][15:0]  d = y_hat_r[1][31:16]
                        mul_a4 = $signed(H_r[1][1][15:0]) - $signed(H_r[1][1][31:16]); 
                        mul_b4 = y_hat_r[1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[1][15:0]) + $signed(y_hat_r[1][31:16]);
                        mul_b5 = H_r[1][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[1][31:16]) - $signed(y_hat_r[1][15:0]);
                        mul_b6 = H_r[1][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd4: begin
                        H_w[0][1] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[1][1] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][1][15:0]  b = H_r[2][1][31:16]  c = y_hat_r[2][15:0]  d = y_hat_r[2][31:16]
                        mul_a1 = $signed(H_r[2][1][15:0]) - $signed(H_r[2][1][31:16]); 
                        mul_b1 = y_hat_r[2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[2][15:0]) + $signed(y_hat_r[2][31:16]);
                        mul_b2 = H_r[2][1][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[2][31:16]) - $signed(y_hat_r[2][15:0]);
                        mul_b3 = H_r[2][1][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][1][15:0]  b = H_r[3][1][31:16]  c = y_hat_r[3][15:0]  d = y_hat_r[3][31:16]
                        mul_a4 = $signed(H_r[3][1][15:0]) - $signed(H_r[3][1][31:16]); 
                        mul_b4 = y_hat_r[3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[3][15:0]) + $signed(y_hat_r[3][31:16]);
                        mul_b5 = H_r[3][1][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[3][31:16]) - $signed(y_hat_r[3][15:0]);
                        mul_b6 = H_r[3][1][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd5: begin
                        H_w[2][1] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[3][1] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[0][2][15:0]  b = H_r[0][2][31:16]  c = y_hat_r[0][15:0]  d = y_hat_r[0][31:16]
                        mul_a1 = $signed(H_r[0][2][15:0]) - $signed(H_r[0][2][31:16]); 
                        mul_b1 = y_hat_r[0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[0][15:0]) + $signed(y_hat_r[0][31:16]);
                        mul_b2 = H_r[0][2][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[0][31:16]) - $signed(y_hat_r[0][15:0]);
                        mul_b3 = H_r[0][2][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][2][15:0]  b = H_r[1][2][31:16]  c = y_hat_r[1][15:0]  d = y_hat_r[1][31:16]
                        mul_a4 = $signed(H_r[1][2][15:0]) - $signed(H_r[1][2][31:16]); 
                        mul_b4 = y_hat_r[1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[1][15:0]) + $signed(y_hat_r[1][31:16]);
                        mul_b5 = H_r[1][2][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[1][31:16]) - $signed(y_hat_r[1][15:0]);
                        mul_b6 = H_r[1][2][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd6: begin
                        H_w[0][2] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[1][2] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][2][15:0]  b = H_r[2][2][31:16]  c = y_hat_r[2][15:0]  d = y_hat_r[2][31:16]
                        mul_a1 = $signed(H_r[2][2][15:0]) - $signed(H_r[2][2][31:16]); 
                        mul_b1 = y_hat_r[2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[2][15:0]) + $signed(y_hat_r[2][31:16]);
                        mul_b2 = H_r[2][2][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[2][31:16]) - $signed(y_hat_r[2][15:0]);
                        mul_b3 = H_r[2][2][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][2][15:0]  b = H_r[3][2][31:16]  c = y_hat_r[3][15:0]  d = y_hat_r[3][31:16]
                        mul_a4 = $signed(H_r[3][2][15:0]) - $signed(H_r[3][2][31:16]); 
                        mul_b4 = y_hat_r[3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[3][15:0]) + $signed(y_hat_r[3][31:16]);
                        mul_b5 = H_r[3][2][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[3][31:16]) - $signed(y_hat_r[3][15:0]);
                        mul_b6 = H_r[3][2][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd7: begin
                        H_w[2][2] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[3][2] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[0][3][15:0]  b = H_r[0][3][31:16]  c = y_hat_r[0][15:0]  d = y_hat_r[0][31:16]
                        mul_a1 = $signed(H_r[0][3][15:0]) - $signed(H_r[0][3][31:16]); 
                        mul_b1 = y_hat_r[0][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[0][15:0]) + $signed(y_hat_r[0][31:16]);
                        mul_b2 = H_r[0][3][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[0][31:16]) - $signed(y_hat_r[0][15:0]);
                        mul_b3 = H_r[0][3][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[1][3][15:0]  b = H_r[1][3][31:16]  c = y_hat_r[1][15:0]  d = y_hat_r[1][31:16]
                        mul_a4 = $signed(H_r[1][3][15:0]) - $signed(H_r[1][3][31:16]); 
                        mul_b4 = y_hat_r[1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[1][15:0]) + $signed(y_hat_r[1][31:16]);
                        mul_b5 = H_r[1][3][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[1][31:16]) - $signed(y_hat_r[1][15:0]);
                        mul_b6 = H_r[1][3][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd8: begin
                        H_w[0][3] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[1][3] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = H_r[2][3][15:0]  b = H_r[2][3][31:16]  c = y_hat_r[2][15:0]  d = y_hat_r[2][31:16]
                        mul_a1 = $signed(H_r[2][3][15:0]) - $signed(H_r[2][3][31:16]); 
                        mul_b1 = y_hat_r[2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(y_hat_r[2][15:0]) + $signed(y_hat_r[2][31:16]);
                        mul_b2 = H_r[2][3][31:16];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(y_hat_r[2][31:16]) - $signed(y_hat_r[2][15:0]);
                        mul_b3 = H_r[2][3][15:0];
                        temp_result_w[2] = mul_c3;
                        // a = H_r[3][3][15:0]  b = H_r[3][3][31:16]  c = y_hat_r[3][15:0]  d = y_hat_r[3][31:16]
                        mul_a4 = $signed(H_r[3][3][15:0]) - $signed(H_r[3][3][31:16]); 
                        mul_b4 = y_hat_r[3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(y_hat_r[3][15:0]) + $signed(y_hat_r[3][31:16]);
                        mul_b5 = H_r[3][3][31:16];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(y_hat_r[3][31:16]) - $signed(y_hat_r[3][15:0]);
                        mul_b6 = H_r[3][3][15:0];
                        temp_result_w[5] = mul_c6;
                    end
                    4'd9: begin
                        H_w[2][3] = ($signed(temp_result_r[0]) + $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[4]));
                        H_w[3][3] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));
                    end
                    4'd10: begin
                        temp3 = ($signed(H_r[0][0]) + $signed(H_r[2][0]));//r
                        temp4 = ($signed(H_r[0][1]) + $signed(H_r[2][1]));
                        temp5 = ($signed(H_r[0][2]) + $signed(H_r[2][2]));
                        temp6 = ($signed(H_r[0][3]) + $signed(H_r[2][3]));
                        temp7 = ($signed(H_r[1][0]) + $signed(H_r[3][0]));//i
                        temp8 = ($signed(H_r[1][1]) + $signed(H_r[3][1]));
                        temp9 = ($signed(H_r[1][2]) + $signed(H_r[3][2]));
                        temp10 = ($signed(H_r[1][3]) + $signed(H_r[3][3]));
                        y_hat_w[0] = {temp7[32], temp7[12 +: 15], temp3[32], temp3[12 +: 15]};
                        y_hat_w[1] = {temp8[32], temp8[12 +: 15], temp4[32], temp4[12 +: 15]};
                        y_hat_w[2] = {temp9[32], temp9[12 +: 15], temp5[32], temp5[12 +: 15]};
                        y_hat_w[3] = {temp10[32], temp10[12 +: 15], temp6[32], temp6[12 +: 15]};
                        mul_iter_w = 0;
                        second_proc_counter_w = 0;
                        rd_vld_w = 1;
                        if (group_number_r == 10) begin
                            last_data_w = 1;
                        end
                    end
                endcase
            end
        end
    endcase
end


// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        state_r <= S_READ;
        for (i = 0; i < 4; i = i + 1) begin
            y_hat_r[i] <= 0;
        end
        r_r     <= 0;
        rd_vld_r <= 0;
        last_data_r <= 0;
        counter_r <= 0;
        record_r  <= 0;
        div_counter_r <= 0;
        group_number_r <= 0;
        mul_iter_r    <= 0;
        sqrt_iter_r    <= 0;
        col_r     <= 1;
        row_r     <= 0;
        first_proc_counter_r <= 0;
        second_proc_counter_r <= 0;
        address_counter_r <= 0;
        sqrt_counter_r <= 0;
        sqrt_en_r <= 0;
        for (i = 0; i < 8; i = i + 1) begin
            temp_result_r[i] <= 0;
            for (j = 0; j < 4; j = j + 1) begin
                H_r[i][j] <= 0;
            end
        end
    end
    else begin
        state_r <= state_w;
        for (i = 0; i < 4; i = i + 1) begin
            y_hat_r[i] <= y_hat_w[i];
        end
        r_r     <= r_w;
        rd_vld_r <= rd_vld_w;
        last_data_r <= last_data_w;
        counter_r <= counter_w;
        record_r <= record_w;
        div_counter_r <= div_counter_w;
        group_number_r <= group_number_w;
        mul_iter_r    <= mul_iter_w;
        sqrt_iter_r    <= sqrt_iter_w;
        col_r    <= col_w;
        row_r    <= row_w;
        first_proc_counter_r <= first_proc_counter_w;
        second_proc_counter_r <= second_proc_counter_w;
        address_counter_r <= address_counter_w;
        sqrt_counter_r <= sqrt_counter_w;
        sqrt_en_r <= sqrt_en_w;
        for (i = 0; i < 8; i = i + 1) begin
            temp_result_r[i] <= temp_result_w[i];
            for (j = 0; j < 4; j = j + 1) begin
                H_r[i][j] <= H_w[i][j];
            end
        end
    end
end
endmodule

module Multiplier (
    input  [15:0] A,
    input  [15:0] B,
    output [31:0] C
);
    assign C = $signed(A) * $signed(B);
endmodule
