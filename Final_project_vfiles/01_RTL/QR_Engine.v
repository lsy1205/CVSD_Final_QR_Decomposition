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
reg         rd_vld_r, rd_vld_w;
reg         last_data_r, last_data_w;
reg [ 39:0] y_hat_r [0:3], y_hat_w [0:3];
reg [319:0] r_r, r_w;

// Control
reg [1:0] state_r, state_w;
reg [7:0] counter_r, counter_w;
reg [1:0] div_counter_r, div_counter_w;
reg [2:0] sqrt_counter_r, sqrt_counter_w;
reg [3:0] first_proc_counter_r, first_proc_counter_w;
reg [3:0] second_proc_counter_r, second_proc_counter_w;
reg [1:0] mul_iter_r, mul_iter_w;
reg [1:0] sqrt_iter_r, sqrt_iter_w;
reg [4:0] address_counter_r, address_counter_w;

// Memory Blocks
wire [7:0] Q [0:3];  // read data
reg  [7:0] A;        // input address
reg  [7:0] D [0:3];  // input data
reg        CEN;      // chip enable
// reg       WEN [0:3]; // write enable equal i_trig?

// Sqrt Blocks
reg         sqrt_en_r, sqrt_en_w;
reg  [32:0] sqrt_a;
wire [16:0] sqrt_result;

// Multiply Blocks
reg  [15:0] mul_a1;
reg  [15:0] mul_a2;
reg  [15:0] mul_a3;
reg  [15:0] mul_a4;
reg  [15:0] mul_a5;
reg  [15:0] mul_a6;
reg  [15:0] mul_a7;
reg  [15:0] mul_a8;

reg  [15:0] mul_b1;
reg  [15:0] mul_b2;
reg  [15:0] mul_b3;
reg  [15:0] mul_b4;
reg  [15:0] mul_b5;
reg  [15:0] mul_b6;
reg  [15:0] mul_b7;
reg  [15:0] mul_b8;

wire [31:0] mul_c1;
wire [31:0] mul_c2;
wire [31:0] mul_c3;
wire [31:0] mul_c4;
wire [31:0] mul_c5;
wire [31:0] mul_c6;
wire [31:0] mul_c7;
wire [31:0] mul_c8;


// Divide Blocks
reg  [15:0] div;
wire [15:0] reciprocal;
wire [ 3:0] div_shift;

//usual store register
reg [31:0] H_r [0:3][0:3], H_w [0:3][0:3];
reg [31:0] temp_result_r[0:7], temp_result_w[0:7];
reg [ 3:0] group_number_r, group_number_w;
reg [ 2:0] col_r, col_w;
reg [ 1:0] row_r, row_w;
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

reg [33:0] temp11;
reg [33:0] temp12;

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
    .WEN(~i_trig),
    .A(A),
    .D(D[0]) // image high 8bit
);

sram_256x8 mem1(
    .Q(Q[1]),
    .CLK(i_clk),
    .CEN(CEN),
    .WEN(~i_trig),
    .A(A),
    .D(D[1]) // image low 8bit
);

sram_256x8 mem2(
    .Q(Q[2]),
    .CLK(i_clk),
    .CEN(CEN),
    .WEN(~i_trig),
    .A(A),
    .D(D[2]) // real high 8bit
);

sram_256x8 mem3(
    .Q(Q[3]),
    .CLK(i_clk),
    .CEN(CEN),
    .WEN(~i_trig),
    .A(A),
    .D(D[3]) // real low 8bit
);

// Divisoin LUT
Div_LUT div0(
    .i_divisor(div),
    .o_reciprocal(reciprocal),
    .o_shift(div_shift)
);

// Multiplier
DW02_mult_2_stage_inst mul0(
    .inst_a(mul_a1),
    .inst_b(mul_b1),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c1)
);

DW02_mult_2_stage_inst mul1(
    .inst_a(mul_a2),
    .inst_b(mul_b2),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c2)
);
DW02_mult_2_stage_inst mul2(
    .inst_a(mul_a3),
    .inst_b(mul_b3),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c3)
);
DW02_mult_2_stage_inst mul3(
    .inst_a(mul_a4),
    .inst_b(mul_b4),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c4)
);
DW02_mult_2_stage_inst mul4(
    .inst_a(mul_a5),
    .inst_b(mul_b5),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c5)
);
DW02_mult_2_stage_inst mul5(
    .inst_a(mul_a6),
    .inst_b(mul_b6),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c6)
);

DW02_mult_2_stage_inst mul6(
    .inst_a(mul_a7),
    .inst_b(mul_b7),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c7)
);

DW02_mult_2_stage_inst mul8(
    .inst_a(mul_a8),
    .inst_b(mul_b8),
    .inst_tc(1'b1),
    .inst_clk(i_clk),
    .product_inst(mul_c8)
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
        default: begin
        end
    endcase
end

// Logic
always @(*) begin
    //data IO
    y_hat_w[0] = y_hat_r[0];
    y_hat_w[1] = y_hat_r[1];
    y_hat_w[2] = y_hat_r[2];
    y_hat_w[3] = y_hat_r[3];

    r_w         = r_r;
    rd_vld_w    = 0;
    last_data_w = 0;

    //sram write
    row_w     = row_r;
    col_w     = col_r;
    counter_w = counter_r;

    //process
    first_proc_counter_w  = first_proc_counter_r;
    second_proc_counter_w = second_proc_counter_r;
    group_number_w        = group_number_r;
    mul_iter_w            = mul_iter_r;
    sqrt_iter_w           = sqrt_iter_r;

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
    A= 0;    
    D[0] = 0;
    D[1] = 0;
    D[2] = 0;
    D[3] = 0;

    H_w[0][0] = H_r[0][0];
    H_w[0][1] = H_r[0][1];
    H_w[0][2] = H_r[0][2];
    H_w[0][3] = H_r[0][3];
    H_w[1][0] = H_r[1][0];
    H_w[1][1] = H_r[1][1];
    H_w[1][2] = H_r[1][2];
    H_w[1][3] = H_r[1][3];
    H_w[2][0] = H_r[2][0];
    H_w[2][1] = H_r[2][1];
    H_w[2][2] = H_r[2][2];
    H_w[2][3] = H_r[2][3];
    H_w[3][0] = H_r[3][0];
    H_w[3][1] = H_r[3][1];
    H_w[3][2] = H_r[3][2];
    H_w[3][3] = H_r[3][3];
    
    //mul
    mul_a1  = 0;
    mul_a2  = 0;
    mul_a3  = 0;
    mul_a4  = 0;
    mul_a5  = 0;
    mul_a6  = 0;
    mul_a7  = 0;
    mul_a8  = 0;
    mul_b1  = 0;
    mul_b2  = 0;
    mul_b3  = 0;
    mul_b4  = 0;
    mul_b5  = 0;
    mul_b6  = 0;
    mul_b7  = 0;
    mul_b8  = 0;
    //temp store data
    temp_result_w[0] = temp_result_r[0];
    temp_result_w[1] = temp_result_r[1];
    temp_result_w[2] = temp_result_r[2];
    temp_result_w[3] = temp_result_r[3];
    temp_result_w[4] = temp_result_r[4];
    temp_result_w[5] = temp_result_r[5];
    temp_result_w[6] = temp_result_r[6];
    temp_result_w[7] = temp_result_r[7];

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
// Pattern    1#: Golden_r = 09be1fb09afc548ef308fb34408855ff0750586b03f04010870080b056ee0c96cfb7d2faf1f0e977
// Pattern    1#: Output_r = 352ac1a0c4e26110e266156da08922ff04e2df140a959f505800818057751832cfb759faea20e970

        S_CALC: begin
            if (first_proc_counter_r != 8) begin
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
                    else if (address_counter_r[3:0] == 15) begin
                        H_w[address_counter_r[1:0]][address_counter_r[3:2]] = {Q[0],Q[1],Q[2],Q[3]};
                        A = {2'b11, group_number_r, 2'b0};
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
                end
                else if (sqrt_iter_r == 1) begin
                    r_w[79:62] = {1'b0,sqrt_result};
                end
                else if (sqrt_iter_r == 2) begin
                    r_w[179:162] = {1'b0,sqrt_result};
                end
                else if (sqrt_iter_r == 3) begin
                    r_w[319:302] = {1'b0,sqrt_result};
                end
                div = sqrt_result[15:0];
                temp_result_w[0] = reciprocal;
                temp_result_w[1] = div_shift;
            end
            if (div_counter_r != 0) begin
                div_counter_w = div_counter_r + 1;
            end
            if (div_counter_r == 2) begin
                mul_a1 = H_r[0][sqrt_iter_r][31:16];
                mul_b1 = temp_result_r[0][15:0];
                mul_a2 = H_r[0][sqrt_iter_r][15:0];
                mul_b2 = temp_result_r[0][15:0];
                mul_a3 = H_r[1][sqrt_iter_r][31:16];
                mul_b3 = temp_result_r[0][15:0];
                mul_a4 = H_r[1][sqrt_iter_r][15:0];
                mul_b4 = temp_result_r[0][15:0];
                mul_a5 = H_r[2][sqrt_iter_r][31:16];
                mul_b5 = temp_result_r[0][15:0];
                mul_a6 = H_r[2][sqrt_iter_r][15:0];
                mul_b6 = temp_result_r[0][15:0];
                mul_a7 = H_r[3][sqrt_iter_r][31:16];
                mul_b7 = temp_result_r[0][15:0];
                mul_a8 = H_r[3][sqrt_iter_r][15:0];
                mul_b8 = temp_result_r[0][15:0];
            end
            if (div_counter_r == 3) begin
                div_counter_w = 0;
                second_proc_counter_w = 1;

                temp[30:0]                 = mul_c1[30:0] << (temp_result_r[1]);
                H_w[0][sqrt_iter_r][31:16] = {mul_c1[31], temp[30:16]};
                temp2[30:0]                = mul_c2[30:0] << (temp_result_r[1]);
                H_w[0][sqrt_iter_r][15:0]  = {mul_c2[31], temp2[30:16]};
                temp3[30:0]                = mul_c3[30:0] << (temp_result_r[1]);
                H_w[1][sqrt_iter_r][31:16] = {mul_c3[31], temp3[30:16]};
                temp4[30:0]                = mul_c4[30:0] << (temp_result_r[1]);
                H_w[1][sqrt_iter_r][15:0]  = {mul_c4[31], temp4[30:16]};
                temp5[30:0]                = mul_c5[30:0] << (temp_result_r[1]);
                H_w[2][sqrt_iter_r][31:16] = {mul_c5[31], temp5[30:16]};
                temp6[30:0]                = mul_c6[30:0] << (temp_result_r[1]);
                H_w[2][sqrt_iter_r][15:0]  = {mul_c6[31], temp6[30:16]};
                temp7[30:0]                = mul_c7[30:0] << (temp_result_r[1]);
                H_w[3][sqrt_iter_r][31:16] = {mul_c7[31], temp7[30:16]};
                temp8[30:0]                = mul_c8[30:0] << (temp_result_r[1]);
                H_w[3][sqrt_iter_r][15:0]  = {mul_c8[31], temp8[30:16]};

                sqrt_iter_w = sqrt_iter_r + 1;
            end
            // multipliers folding and main logic
            case (first_proc_counter_r)
                4'd2: begin
                    mul_a1 = H_r[0][0][31:16];
                    mul_b1 = H_r[0][0][31:16];
                    mul_a2 = H_r[0][0][15:0];
                    mul_b2 = H_r[0][0][15:0];
                end
                4'd3: begin
                    temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                    mul_a1 = H_r[1][0][31:16];
                    mul_b1 = H_r[1][0][31:16];
                    mul_a2 = H_r[1][0][15:0];
                    mul_b2 = H_r[1][0][15:0];
                end
                4'd4: begin
                    temp_result_w[1] = mul_c1[30:0] + mul_c2[30:0];
                    mul_a1 = H_r[2][0][31:16];
                    mul_b1 = H_r[2][0][31:16];
                    mul_a2 = H_r[2][0][15:0];
                    mul_b2 = H_r[2][0][15:0];
                end
                4'd5: begin
                    temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                    mul_a1 = H_r[3][0][31:16];
                    mul_b1 = H_r[3][0][31:16];
                    mul_a2 = H_r[3][0][15:0];
                    mul_b2 = H_r[3][0][15:0];
                end
                4'd6: begin
                    temp_result_w[3] = mul_c1[30:0] + mul_c2[30:0];
                end
                4'd7: begin
                    temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                    temp_result_w[6] = temp[31:0];
                    sqrt_en_w = 1;
                    sqrt_counter_w = 1;
                end
                default: begin

                end
            endcase
            
            // complex inner product
            // r = c(a-b) + b(c+d)
            // i = c(a-b) + a(d-c)
            if (mul_iter_r == 0) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        mul_a1 = H_r[0][0][15:0];
                        mul_b1 = H_r[0][1][15:0];
                        mul_a2 = H_r[0][0][31:16];
                        mul_b2 = H_r[0][1][31:16];
                        mul_a3 = H_r[0][0][15:0];
                        mul_b3 = H_r[0][1][31:16];
                        mul_a4 = H_r[0][0][31:16];
                        mul_b4 = H_r[0][1][15:0];

                        mul_a5 = H_r[1][0][15:0];
                        mul_b5 = H_r[1][1][15:0];
                        mul_a6 = H_r[1][0][31:16];
                        mul_b6 = H_r[1][1][31:16];
                        mul_a7 = H_r[1][0][15:0];
                        mul_b7 = H_r[1][1][31:16];
                        mul_a8 = H_r[1][0][31:16];
                        mul_b8 = H_r[1][1][15:0];

                    end
                    4'd2: begin
                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][0][15:0];
                        mul_b1 = H_r[2][1][15:0];
                        mul_a2 = H_r[2][0][31:16];
                        mul_b2 = H_r[2][1][31:16];
                        mul_a3 = H_r[2][0][15:0];
                        mul_b3 = H_r[2][1][31:16];
                        mul_a4 = H_r[2][0][31:16];
                        mul_b4 = H_r[2][1][15:0];

                        mul_a5 = H_r[3][0][15:0];
                        mul_b5 = H_r[3][1][15:0];
                        mul_a6 = H_r[3][0][31:16];
                        mul_b6 = H_r[3][1][31:16];
                        mul_a7 = H_r[3][0][15:0];
                        mul_b7 = H_r[3][1][31:16];
                        mul_a8 = H_r[3][0][31:16];
                        mul_b8 = H_r[3][1][15:0];
                    end
                    4'd3: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][0][15:0];
                        mul_b1 = H_r[0][2][15:0];
                        mul_a2 = H_r[0][0][31:16];
                        mul_b2 = H_r[0][2][31:16];
                        mul_a3 = H_r[0][0][15:0];
                        mul_b3 = H_r[0][2][31:16];
                        mul_a4 = H_r[0][0][31:16];
                        mul_b4 = H_r[0][2][15:0];

                        mul_a5 = H_r[1][0][15:0];
                        mul_b5 = H_r[1][2][15:0];
                        mul_a6 = H_r[1][0][31:16];
                        mul_b6 = H_r[1][2][31:16];
                        mul_a7 = H_r[1][0][15:0];
                        mul_b7 = H_r[1][2][31:16];
                        mul_a8 = H_r[1][0][31:16];
                        mul_b8 = H_r[1][2][15:0];
                    end
                    4'd4: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[59:40] = {temp2[33],temp2[30:12]}; // R12
                        r_w[39:20] = {temp[33],temp[30:12]};

                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][0][15:0];
                        mul_b1 = H_r[2][2][15:0];
                        mul_a2 = H_r[2][0][31:16];
                        mul_b2 = H_r[2][2][31:16];
                        mul_a3 = H_r[2][0][15:0];
                        mul_b3 = H_r[2][2][31:16];
                        mul_a4 = H_r[2][0][31:16];
                        mul_b4 = H_r[2][2][15:0];

                        mul_a5 = H_r[3][0][15:0];
                        mul_b5 = H_r[3][2][15:0];
                        mul_a6 = H_r[3][0][31:16];
                        mul_b6 = H_r[3][2][31:16];
                        mul_a7 = H_r[3][0][15:0];
                        mul_b7 = H_r[3][2][31:16];
                        mul_a8 = H_r[3][0][31:16];
                        mul_b8 = H_r[3][2][15:0];
                    end
                    4'd5: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][0][15:0];
                        mul_b1 = H_r[0][3][15:0];
                        mul_a2 = H_r[0][0][31:16];
                        mul_b2 = H_r[0][3][31:16];
                        mul_a3 = H_r[0][0][15:0];
                        mul_b3 = H_r[0][3][31:16];
                        mul_a4 = H_r[0][0][31:16];
                        mul_b4 = H_r[0][3][15:0];

                        mul_a5 = H_r[1][0][15:0];
                        mul_b5 = H_r[1][3][15:0];
                        mul_a6 = H_r[1][0][31:16];
                        mul_b6 = H_r[1][3][31:16];
                        mul_a7 = H_r[1][0][15:0];
                        mul_b7 = H_r[1][3][31:16];
                        mul_a8 = H_r[1][0][31:16];
                        mul_b8 = H_r[1][3][15:0];

                    end
                    4'd6: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[119:100] = {temp2[33],temp2[30:12]}; // R13
                        r_w[99:80] = {temp[33],temp[30:12]};

                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][0][15:0];
                        mul_b1 = H_r[2][3][15:0];
                        mul_a2 = H_r[2][0][31:16];
                        mul_b2 = H_r[2][3][31:16];
                        mul_a3 = H_r[2][0][15:0];
                        mul_b3 = H_r[2][3][31:16];
                        mul_a4 = H_r[2][0][31:16];
                        mul_b4 = H_r[2][3][15:0];

                        mul_a5 = H_r[3][0][15:0];
                        mul_b5 = H_r[3][3][15:0];
                        mul_a6 = H_r[3][0][31:16];
                        mul_b6 = H_r[3][3][31:16];
                        mul_a7 = H_r[3][0][15:0];
                        mul_b7 = H_r[3][3][31:16];
                        mul_a8 = H_r[3][0][31:16];
                        mul_b8 = H_r[3][3][15:0];
                    end
                    4'd7: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = {r_r[39], r_r[22+:15]};
                        mul_b1 = H_r[0][0][15:0];
                        mul_a2 = {r_r[59], r_r[42+:15]};
                        mul_b2 = H_r[0][0][31:16];
                        mul_a3 = {r_r[39], r_r[22+:15]};
                        mul_b3 = H_r[0][0][31:16];
                        mul_a4 = {r_r[59], r_r[42+:15]};
                        mul_b4 = H_r[0][0][15:0];

                        mul_a5 = {r_r[39], r_r[22+:15]};
                        mul_b5 = H_r[1][0][15:0];
                        mul_a6 = {r_r[59], r_r[42+:15]};
                        mul_b6 = H_r[1][0][31:16];
                        mul_a7 = {r_r[39], r_r[22+:15]};
                        mul_b7 = H_r[1][0][31:16];
                        mul_a8 = {r_r[59], r_r[42+:15]};
                        mul_b8 = H_r[1][0][15:0];

                    end
                    4'd8: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[219:200] = {temp2[33],temp2[30:12]}; //R14
                        r_w[199:180] = {temp[33],temp[30:12]};

                        H_w[0][1][15:0] = $signed(H_r[0][1][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][1][31:16] = $signed(H_r[0][1][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][1][15:0] = $signed(H_r[1][1][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][1][31:16] = $signed(H_r[1][1][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = {r_r[39], r_r[22+:15]};
                        mul_b1 = H_r[2][0][15:0];
                        mul_a2 = {r_r[59], r_r[42+:15]};
                        mul_b2 = H_r[2][0][31:16];
                        mul_a3 = {r_r[39], r_r[22+:15]};
                        mul_b3 = H_r[2][0][31:16];
                        mul_a4 = {r_r[59], r_r[42+:15]};
                        mul_b4 = H_r[2][0][15:0];

                        mul_a5 = {r_r[39], r_r[22+:15]};
                        mul_b5 = H_r[3][0][15:0];
                        mul_a6 = {r_r[59], r_r[42+:15]};
                        mul_b6 = H_r[3][0][31:16];
                        mul_a7 = {r_r[39], r_r[22+:15]};
                        mul_b7 = H_r[3][0][31:16];
                        mul_a8 = {r_r[59], r_r[42+:15]};
                        mul_b8 = H_r[3][0][15:0];
                    end
                    4'd9: begin
                        H_w[2][1][15:0] = $signed(H_r[2][1][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][1][31:16] = $signed(H_r[2][1][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][1][15:0] = $signed(H_r[3][1][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][1][31:16] = $signed(H_r[3][1][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        
                        mul_a1 = H_r[0][1][31:16];
                        mul_b1 = H_r[0][1][31:16];
                        mul_a2 = H_r[0][1][15:0];
                        mul_b2 = H_r[0][1][15:0];
                        mul_a3 = H_r[1][1][31:16];
                        mul_b3 = H_r[1][1][31:16];
                        mul_a4 = H_r[1][1][15:0];
                        mul_b4 = H_r[1][1][15:0];
                    end
                    4'd10: begin
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];
                        mul_a1 = H_r[2][1][31:16];
                        mul_b1 = H_r[2][1][31:16];
                        mul_a2 = H_r[2][1][15:0];
                        mul_b2 = H_r[2][1][15:0];
                        mul_a3 = H_r[3][1][31:16];
                        mul_b3 = H_r[3][1][31:16];
                        mul_a4 = H_r[3][1][15:0];
                        mul_b4 = H_r[3][1][15:0];
                    end
                    4'd11: begin
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];

                        mul_a1 = {r_r[99], r_r[82+:15]};
                        mul_b1 = H_r[0][0][15:0];
                        mul_a2 = {r_r[119], r_r[102+:15]};
                        mul_b2 = H_r[0][0][31:16];
                        mul_a3 = {r_r[99], r_r[82+:15]};
                        mul_b3 = H_r[0][0][31:16];
                        mul_a4 = {r_r[119], r_r[102+:15]};
                        mul_b4 = H_r[0][0][15:0];

                        mul_a5 = {r_r[99], r_r[82+:15]};
                        mul_b5 = H_r[1][0][15:0];
                        mul_a6 = {r_r[119], r_r[102+:15]};
                        mul_b6 = H_r[1][0][31:16];
                        mul_a7 = {r_r[99], r_r[82+:15]};
                        mul_b7 = H_r[1][0][31:16];
                        mul_a8 = {r_r[119], r_r[102+:15]};
                        mul_b8 = H_r[1][0][15:0];
                    end
                    4'd12: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;

                        H_w[0][2][15:0] = $signed(H_r[0][2][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][2][31:16] = $signed(H_r[0][2][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][2][15:0] = $signed(H_r[1][2][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][2][31:16] = $signed(H_r[1][2][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = {r_r[99], r_r[82+:15]};
                        mul_b1 = H_r[2][0][15:0];
                        mul_a2 = {r_r[119], r_r[102+:15]};
                        mul_b2 = H_r[2][0][31:16];
                        mul_a3 = {r_r[99], r_r[82+:15]};
                        mul_b3 = H_r[2][0][31:16];
                        mul_a4 = {r_r[119], r_r[102+:15]};
                        mul_b4 = H_r[2][0][15:0];

                        mul_a5 = {r_r[99], r_r[82+:15]};
                        mul_b5 = H_r[3][0][15:0];
                        mul_a6 = {r_r[119], r_r[102+:15]};
                        mul_b6 = H_r[3][0][31:16];
                        mul_a7 = {r_r[99], r_r[82+:15]};
                        mul_b7 = H_r[3][0][31:16];
                        mul_a8 = {r_r[119], r_r[102+:15]};
                        mul_b8 = H_r[3][0][15:0];
                    end
                    4'd13: begin
                        H_w[2][2][15:0] = $signed(H_r[2][2][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][2][31:16] = $signed(H_r[2][2][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][2][15:0] = $signed(H_r[3][2][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][2][31:16] = $signed(H_r[3][2][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        
                        mul_a1 = {r_r[199], r_r[182+:15]};
                        mul_b1 = H_r[0][0][15:0];
                        mul_a2 = {r_r[219], r_r[202+:15]};
                        mul_b2 = H_r[0][0][31:16];
                        mul_a3 = {r_r[199], r_r[182+:15]};
                        mul_b3 = H_r[0][0][31:16];
                        mul_a4 = {r_r[219], r_r[202+:15]};
                        mul_b4 = H_r[0][0][15:0];

                        mul_a5 = {r_r[199], r_r[182+:15]};
                        mul_b5 = H_r[1][0][15:0];
                        mul_a6 = {r_r[219], r_r[202+:15]};
                        mul_b6 = H_r[1][0][31:16];
                        mul_a7 = {r_r[199], r_r[182+:15]};
                        mul_b7 = H_r[1][0][31:16];
                        mul_a8 = {r_r[219], r_r[202+:15]};
                        mul_b8 = H_r[1][0][15:0];
                    end
                    4'd14: begin
                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = {r_r[199], r_r[182+:15]};
                        mul_b1 = H_r[2][0][15:0];
                        mul_a2 = {r_r[219], r_r[202+:15]};
                        mul_b2 = H_r[2][0][31:16];
                        mul_a3 = {r_r[199], r_r[182+:15]};
                        mul_b3 = H_r[2][0][31:16];
                        mul_a4 = {r_r[219], r_r[202+:15]};
                        mul_b4 = H_r[2][0][15:0];

                        mul_a5 = {r_r[199], r_r[182+:15]};
                        mul_b5 = H_r[3][0][15:0];
                        mul_a6 = {r_r[219], r_r[202+:15]};
                        mul_b6 = H_r[3][0][31:16];
                        mul_a7 = {r_r[199], r_r[182+:15]};
                        mul_b7 = H_r[3][0][31:16];
                        mul_a8 = {r_r[219], r_r[202+:15]};
                        mul_b8 = H_r[3][0][15:0];
                    end
                    4'd15: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                    default: begin

                    end
                endcase
            end
            if (mul_iter_r == 1) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        mul_a1 = H_r[0][1][15:0];
                        mul_b1 = H_r[0][2][15:0];
                        mul_a2 = H_r[0][1][31:16];
                        mul_b2 = H_r[0][2][31:16];
                        mul_a3 = H_r[0][1][15:0];
                        mul_b3 = H_r[0][2][31:16];
                        mul_a4 = H_r[0][1][31:16];
                        mul_b4 = H_r[0][2][15:0];

                        mul_a5 = H_r[1][1][15:0];
                        mul_b5 = H_r[1][2][15:0];
                        mul_a6 = H_r[1][1][31:16];
                        mul_b6 = H_r[1][2][31:16];
                        mul_a7 = H_r[1][1][15:0];
                        mul_b7 = H_r[1][2][31:16];
                        mul_a8 = H_r[1][1][31:16];
                        mul_b8 = H_r[1][2][15:0];

                    end
                    4'd2: begin
                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));
                        mul_a1 = H_r[2][1][15:0];
                        mul_b1 = H_r[2][2][15:0];
                        mul_a2 = H_r[2][1][31:16];
                        mul_b2 = H_r[2][2][31:16];
                        mul_a3 = H_r[2][1][15:0];
                        mul_b3 = H_r[2][2][31:16];
                        mul_a4 = H_r[2][1][31:16];
                        mul_b4 = H_r[2][2][15:0];

                        mul_a5 = H_r[3][1][15:0];
                        mul_b5 = H_r[3][2][15:0];
                        mul_a6 = H_r[3][1][31:16];
                        mul_b6 = H_r[3][2][31:16];
                        mul_a7 = H_r[3][1][15:0];
                        mul_b7 = H_r[3][2][31:16];
                        mul_a8 = H_r[3][1][31:16];
                        mul_b8 = H_r[3][2][15:0];
                    end
                    4'd3: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][1][15:0];
                        mul_b1 = H_r[0][3][15:0];
                        mul_a2 = H_r[0][1][31:16];
                        mul_b2 = H_r[0][3][31:16];
                        mul_a3 = H_r[0][1][15:0];
                        mul_b3 = H_r[0][3][31:16];
                        mul_a4 = H_r[0][1][31:16];
                        mul_b4 = H_r[0][3][15:0];

                        mul_a5 = H_r[1][1][15:0];
                        mul_b5 = H_r[1][3][15:0];
                        mul_a6 = H_r[1][1][31:16];
                        mul_b6 = H_r[1][3][31:16];
                        mul_a7 = H_r[1][1][15:0];
                        mul_b7 = H_r[1][3][31:16];
                        mul_a8 = H_r[1][1][31:16];
                        mul_b8 = H_r[1][3][15:0];
                    end
                    4'd4: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[159:140] = {temp2[33],temp2[30:12]}; // R23
                        r_w[139:120] = {temp[33],temp[30:12]};
                        
                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][1][15:0];
                        mul_b1 = H_r[2][3][15:0];
                        mul_a2 = H_r[2][1][31:16];
                        mul_b2 = H_r[2][3][31:16];
                        mul_a3 = H_r[2][1][15:0];
                        mul_b3 = H_r[2][3][31:16];
                        mul_a4 = H_r[2][1][31:16];
                        mul_b4 = H_r[2][3][15:0];

                        mul_a5 = H_r[3][1][15:0];
                        mul_b5 = H_r[3][3][15:0];
                        mul_a6 = H_r[3][1][31:16];
                        mul_b6 = H_r[3][3][31:16];
                        mul_a7 = H_r[3][1][15:0];
                        mul_b7 = H_r[3][3][31:16];
                        mul_a8 = H_r[3][1][31:16];
                        mul_b8 = H_r[3][3][15:0];
                    end
                    4'd5: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = {r_r[139], r_r[122+:15]};
                        mul_b1 = H_r[0][1][15:0];
                        mul_a2 = {r_r[159], r_r[142+:15]};
                        mul_b2 = H_r[0][1][31:16];
                        mul_a3 = {r_r[139], r_r[122+:15]};
                        mul_b3 = H_r[0][1][31:16];
                        mul_a4 = {r_r[159], r_r[142+:15]};
                        mul_b4 = H_r[0][1][15:0];

                        mul_a5 = {r_r[139], r_r[122+:15]};
                        mul_b5 = H_r[1][1][15:0];
                        mul_a6 = {r_r[159], r_r[142+:15]};
                        mul_b6 = H_r[1][1][31:16];
                        mul_a7 = {r_r[139], r_r[122+:15]};
                        mul_b7 = H_r[1][1][31:16];
                        mul_a8 = {r_r[159], r_r[142+:15]};
                        mul_b8 = H_r[1][1][15:0];
                    end
                    4'd6: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[259:240] = {temp2[33],temp2[30:12]}; // R24
                        r_w[239:220] = {temp[33],temp[30:12]};

                        H_w[0][2][15:0] = $signed(H_r[0][2][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][2][31:16] = $signed(H_r[0][2][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][2][15:0] = $signed(H_r[1][2][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][2][31:16] = $signed(H_r[1][2][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = {r_r[139], r_r[122+:15]};
                        mul_b1 = H_r[2][1][15:0];
                        mul_a2 = {r_r[159], r_r[142+:15]};
                        mul_b2 = H_r[2][1][31:16];
                        mul_a3 = {r_r[139], r_r[122+:15]};
                        mul_b3 = H_r[2][1][31:16];
                        mul_a4 = {r_r[159], r_r[142+:15]};
                        mul_b4 = H_r[2][1][15:0];

                        mul_a5 = {r_r[139], r_r[122+:15]};
                        mul_b5 = H_r[3][1][15:0];
                        mul_a6 = {r_r[159], r_r[142+:15]};
                        mul_b6 = H_r[3][1][31:16];
                        mul_a7 = {r_r[139], r_r[122+:15]};
                        mul_b7 = H_r[3][1][31:16];
                        mul_a8 = {r_r[159], r_r[142+:15]};
                        mul_b8 = H_r[3][1][15:0];
                    end
                    4'd7: begin
                        H_w[2][2][15:0] = $signed(H_r[2][2][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][2][31:16] = $signed(H_r[2][2][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][2][15:0] = $signed(H_r[3][2][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][2][31:16] = $signed(H_r[3][2][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        
                        mul_a1 = H_r[0][2][31:16];
                        mul_b1 = H_r[0][2][31:16];
                        mul_a2 = H_r[0][2][15:0];
                        mul_b2 = H_r[0][2][15:0];
                        mul_a3 = H_r[1][2][31:16];
                        mul_b3 = H_r[1][2][31:16];
                        mul_a4 = H_r[1][2][15:0];
                        mul_b4 = H_r[1][2][15:0];
                    end
                    4'd8: begin
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];
                        mul_a1 = H_r[2][2][31:16];
                        mul_b1 = H_r[2][2][31:16];
                        mul_a2 = H_r[2][2][15:0];
                        mul_b2 = H_r[2][2][15:0];
                        mul_a3 = H_r[3][2][31:16];
                        mul_b3 = H_r[3][2][31:16];
                        mul_a4 = H_r[3][2][15:0];
                        mul_b4 = H_r[3][2][15:0];
                    end
                    4'd9: begin
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];

                        mul_a1 = {r_r[239], r_r[222+:15]};
                        mul_b1 = H_r[0][1][15:0];
                        mul_a2 = {r_r[259], r_r[242+:15]};
                        mul_b2 = H_r[0][1][31:16];
                        mul_a3 = {r_r[239], r_r[222+:15]};
                        mul_b3 = H_r[0][1][31:16];
                        mul_a4 = {r_r[259], r_r[242+:15]};
                        mul_b4 = H_r[0][1][15:0];

                        mul_a5 = {r_r[239], r_r[222+:15]};
                        mul_b5 = H_r[1][1][15:0];
                        mul_a6 = {r_r[259], r_r[242+:15]};
                        mul_b6 = H_r[1][1][31:16];
                        mul_a7 = {r_r[239], r_r[222+:15]};
                        mul_b7 = H_r[1][1][31:16];
                        mul_a8 = {r_r[259], r_r[242+:15]};
                        mul_b8 = H_r[1][1][15:0];
                    end
                    4'd10: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;

                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = {r_r[239], r_r[222+:15]};
                        mul_b1 = H_r[2][1][15:0];
                        mul_a2 = {r_r[259], r_r[242+:15]};
                        mul_b2 = H_r[2][1][31:16];
                        mul_a3 = {r_r[239], r_r[222+:15]};
                        mul_b3 = H_r[2][1][31:16];
                        mul_a4 = {r_r[259], r_r[242+:15]};
                        mul_b4 = H_r[2][1][15:0];

                        mul_a5 = {r_r[239], r_r[222+:15]};
                        mul_b5 = H_r[3][1][15:0];
                        mul_a6 = {r_r[259], r_r[242+:15]};
                        mul_b6 = H_r[3][1][31:16];
                        mul_a7 = {r_r[239], r_r[222+:15]};
                        mul_b7 = H_r[3][1][31:16];
                        mul_a8 = {r_r[259], r_r[242+:15]};
                        mul_b8 = H_r[3][1][15:0];
                    end
                    4'd11: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                    default: begin

                    end
                endcase
            end
            if (mul_iter_r == 2) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        mul_a1 = H_r[0][2][15:0];
                        mul_b1 = H_r[0][3][15:0];
                        mul_a2 = H_r[0][2][31:16];
                        mul_b2 = H_r[0][3][31:16];
                        mul_a3 = H_r[0][2][15:0];
                        mul_b3 = H_r[0][3][31:16];
                        mul_a4 = H_r[0][2][31:16];
                        mul_b4 = H_r[0][3][15:0];

                        mul_a5 = H_r[1][2][15:0];
                        mul_b5 = H_r[1][3][15:0];
                        mul_a6 = H_r[1][2][31:16];
                        mul_b6 = H_r[1][3][31:16];
                        mul_a7 = H_r[1][2][15:0];
                        mul_b7 = H_r[1][3][31:16];
                        mul_a8 = H_r[1][2][31:16];
                        mul_b8 = H_r[1][3][15:0];

                    end
                    4'd2: begin
                        temp_result_w[0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));
                        mul_a1 = H_r[2][2][15:0];
                        mul_b1 = H_r[2][3][15:0];
                        mul_a2 = H_r[2][2][31:16];
                        mul_b2 = H_r[2][3][31:16];
                        mul_a3 = H_r[2][2][15:0];
                        mul_b3 = H_r[2][3][31:16];
                        mul_a4 = H_r[2][2][31:16];
                        mul_b4 = H_r[2][3][15:0];

                        mul_a5 = H_r[3][2][15:0];
                        mul_b5 = H_r[3][3][15:0];
                        mul_a6 = H_r[3][2][31:16];
                        mul_b6 = H_r[3][3][31:16];
                        mul_a7 = H_r[3][2][15:0];
                        mul_b7 = H_r[3][3][31:16];
                        mul_a8 = H_r[3][2][31:16];
                        mul_b8 = H_r[3][3][15:0];
                    end
                    4'd3: begin
                        temp_result_w[2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        temp_result_w[3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));
                    end
                    4'd4: begin
                        temp = ($signed(temp_result_r[0]) + $signed(temp_result_r[2]));
                        temp2 = ($signed(temp_result_r[1]) + $signed(temp_result_r[3]));
                        r_w[299:280] = {temp2[33],temp2[30:12]}; // R34
                        r_w[279:260] = {temp[33],temp[30:12]};

                    end
                    4'd5: begin
                        mul_a1 = {r_r[279], r_r[262+:15]};
                        mul_b1 = H_r[0][2][15:0];
                        mul_a2 = {r_r[299], r_r[282+:15]};
                        mul_b2 = H_r[0][2][31:16];
                        mul_a3 = {r_r[279], r_r[262+:15]};
                        mul_b3 = H_r[0][2][31:16];
                        mul_a4 = {r_r[299], r_r[282+:15]};
                        mul_b4 = H_r[0][2][15:0];

                        mul_a5 = {r_r[279], r_r[262+:15]};
                        mul_b5 = H_r[1][2][15:0];
                        mul_a6 = {r_r[299], r_r[282+:15]};
                        mul_b6 = H_r[1][2][31:16];
                        mul_a7 = {r_r[279], r_r[262+:15]};
                        mul_b7 = H_r[1][2][31:16];
                        mul_a8 = {r_r[299], r_r[282+:15]};
                        mul_b8 = H_r[1][2][15:0];
                    end
                    4'd6: begin
                        H_w[0][3][15:0] = $signed(H_r[0][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[0][3][31:16] = $signed(H_r[0][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[1][3][15:0] = $signed(H_r[1][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[1][3][31:16] = $signed(H_r[1][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});
                        mul_a1 = {r_r[279], r_r[262+:15]};
                        mul_b1 = H_r[2][2][15:0];
                        mul_a2 = {r_r[299], r_r[282+:15]};
                        mul_b2 = H_r[2][2][31:16];
                        mul_a3 = {r_r[279], r_r[262+:15]};
                        mul_b3 = H_r[2][2][31:16];
                        mul_a4 = {r_r[299], r_r[282+:15]};
                        mul_b4 = H_r[2][2][15:0];

                        mul_a5 = {r_r[279], r_r[262+:15]};
                        mul_b5 = H_r[3][2][15:0];
                        mul_a6 = {r_r[299], r_r[282+:15]};
                        mul_b6 = H_r[3][2][31:16];
                        mul_a7 = {r_r[279], r_r[262+:15]};
                        mul_b7 = H_r[3][2][31:16];
                        mul_a8 = {r_r[299], r_r[282+:15]};
                        mul_b8 = H_r[3][2][15:0];
                    end
                    4'd7: begin
                        H_w[2][3][15:0] = $signed(H_r[2][3][15:0]) - $signed({mul_c1[31], mul_c1[14+:15]}) + $signed({mul_c2[31], mul_c2[14+:15]});
                        H_w[2][3][31:16] = $signed(H_r[2][3][31:16]) - $signed({mul_c3[31], mul_c3[14+:15]}) - $signed({mul_c4[31], mul_c4[14+:15]});
                        H_w[3][3][15:0] = $signed(H_r[3][3][15:0]) - $signed({mul_c5[31], mul_c5[14+:15]}) + $signed({mul_c6[31], mul_c6[14+:15]});
                        H_w[3][3][31:16] = $signed(H_r[3][3][31:16]) - $signed({mul_c7[31], mul_c7[14+:15]}) - $signed({mul_c8[31], mul_c8[14+:15]});

                        mul_a1 = H_r[0][3][31:16];
                        mul_b1 = H_r[0][3][31:16];
                        mul_a2 = H_r[0][3][15:0];
                        mul_b2 = H_r[0][3][15:0];
                        mul_a3 = H_r[1][3][31:16];
                        mul_b3 = H_r[1][3][31:16];
                        mul_a4 = H_r[1][3][15:0];
                        mul_b4 = H_r[1][3][15:0];
                    end
                    4'd8: begin
                        temp_result_w[0] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[1] = mul_c3[30:0] + mul_c4[30:0];

                        mul_a1 = H_r[2][3][31:16];
                        mul_b1 = H_r[2][3][31:16];
                        mul_a2 = H_r[2][3][15:0];
                        mul_b2 = H_r[2][3][15:0];
                        mul_a3 = H_r[3][3][31:16];
                        mul_b3 = H_r[3][3][31:16];
                        mul_a4 = H_r[3][3][15:0];
                        mul_b4 = H_r[3][3][15:0];
                    end
                    4'd9: begin
                        temp_result_w[2] = mul_c1[30:0] + mul_c2[30:0];
                        temp_result_w[3] = mul_c3[30:0] + mul_c4[30:0];
                    end
                    4'd10: begin
                        temp = (temp_result_r[0] + temp_result_r[1]) + (temp_result_r[2] + temp_result_r[3]);
                        temp_result_w[6] = temp[31:0];
                        sqrt_en_w = 1;
                        sqrt_counter_w = 1;
                        second_proc_counter_w = 0;
                        mul_iter_w = mul_iter_r + 1;
                    end
                    default: begin

                    end
                endcase
            end
            if (mul_iter_r == 3) begin
                case (second_proc_counter_r)
                    4'd1: begin
                        mul_a1 = H_r[0][0][15:0];
                        mul_b1 = y_hat_r[0][15:0];
                        mul_a2 = H_r[0][0][31:16];
                        mul_b2 = y_hat_r[0][31:16];
                        mul_a3 = H_r[0][0][15:0];
                        mul_b3 = y_hat_r[0][31:16];
                        mul_a4 = H_r[0][0][31:16];
                        mul_b4 = y_hat_r[0][15:0];

                        mul_a5 = H_r[1][0][15:0];
                        mul_b5 = y_hat_r[1][15:0];
                        mul_a6 = H_r[1][0][31:16];
                        mul_b6 = y_hat_r[1][31:16];
                        mul_a7 = H_r[1][0][15:0];
                        mul_b7 = y_hat_r[1][31:16];
                        mul_a8 = H_r[1][0][31:16];
                        mul_b8 = y_hat_r[1][15:0];
                    end
                    4'd2: begin
                        H_w[0][0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[1][0] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][0][15:0];
                        mul_b1 = y_hat_r[2][15:0];
                        mul_a2 = H_r[2][0][31:16];
                        mul_b2 = y_hat_r[2][31:16];
                        mul_a3 = H_r[2][0][15:0];
                        mul_b3 = y_hat_r[2][31:16];
                        mul_a4 = H_r[2][0][31:16];
                        mul_b4 = y_hat_r[2][15:0];

                        mul_a5 = H_r[3][0][15:0];
                        mul_b5 = y_hat_r[3][15:0];
                        mul_a6 = H_r[3][0][31:16];
                        mul_b6 = y_hat_r[3][31:16];
                        mul_a7 = H_r[3][0][15:0];
                        mul_b7 = y_hat_r[3][31:16];
                        mul_a8 = H_r[3][0][31:16];
                        mul_b8 = y_hat_r[3][15:0];
                    end
                    4'd3: begin
                        H_w[2][0] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[3][0] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][1][15:0];
                        mul_b1 = y_hat_r[0][15:0];
                        mul_a2 = H_r[0][1][31:16];
                        mul_b2 = y_hat_r[0][31:16];
                        mul_a3 = H_r[0][1][15:0];
                        mul_b3 = y_hat_r[0][31:16];
                        mul_a4 = H_r[0][1][31:16];
                        mul_b4 = y_hat_r[0][15:0];

                        mul_a5 = H_r[1][1][15:0];
                        mul_b5 = y_hat_r[1][15:0];
                        mul_a6 = H_r[1][1][31:16];
                        mul_b6 = y_hat_r[1][31:16];
                        mul_a7 = H_r[1][1][15:0];
                        mul_b7 = y_hat_r[1][31:16];
                        mul_a8 = H_r[1][1][31:16];
                        mul_b8 = y_hat_r[1][15:0];
                    end
                    4'd4: begin
                        H_w[0][1] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[1][1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][1][15:0];
                        mul_b1 = y_hat_r[2][15:0];
                        mul_a2 = H_r[2][1][31:16];
                        mul_b2 = y_hat_r[2][31:16];
                        mul_a3 = H_r[2][1][15:0];
                        mul_b3 = y_hat_r[2][31:16];
                        mul_a4 = H_r[2][1][31:16];
                        mul_b4 = y_hat_r[2][15:0];

                        mul_a5 = H_r[3][1][15:0];
                        mul_b5 = y_hat_r[3][15:0];
                        mul_a6 = H_r[3][1][31:16];
                        mul_b6 = y_hat_r[3][31:16];
                        mul_a7 = H_r[3][1][15:0];
                        mul_b7 = y_hat_r[3][31:16];
                        mul_a8 = H_r[3][1][31:16];
                        mul_b8 = y_hat_r[3][15:0];
                    end
                    4'd5: begin
                        H_w[2][1] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[3][1] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][2][15:0];
                        mul_b1 = y_hat_r[0][15:0];
                        mul_a2 = H_r[0][2][31:16];
                        mul_b2 = y_hat_r[0][31:16];
                        mul_a3 = H_r[0][2][15:0];
                        mul_b3 = y_hat_r[0][31:16];
                        mul_a4 = H_r[0][2][31:16];
                        mul_b4 = y_hat_r[0][15:0];

                        mul_a5 = H_r[1][2][15:0];
                        mul_b5 = y_hat_r[1][15:0];
                        mul_a6 = H_r[1][2][31:16];
                        mul_b6 = y_hat_r[1][31:16];
                        mul_a7 = H_r[1][2][15:0];
                        mul_b7 = y_hat_r[1][31:16];
                        mul_a8 = H_r[1][2][31:16];
                        mul_b8 = y_hat_r[1][15:0];
                    end
                    4'd6: begin
                        H_w[0][2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[1][2] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][2][15:0];
                        mul_b1 = y_hat_r[2][15:0];
                        mul_a2 = H_r[2][2][31:16];
                        mul_b2 = y_hat_r[2][31:16];
                        mul_a3 = H_r[2][2][15:0];
                        mul_b3 = y_hat_r[2][31:16];
                        mul_a4 = H_r[2][2][31:16];
                        mul_b4 = y_hat_r[2][15:0];

                        mul_a5 = H_r[3][2][15:0];
                        mul_b5 = y_hat_r[3][15:0];
                        mul_a6 = H_r[3][2][31:16];
                        mul_b6 = y_hat_r[3][31:16];
                        mul_a7 = H_r[3][2][15:0];
                        mul_b7 = y_hat_r[3][31:16];
                        mul_a8 = H_r[3][2][31:16];
                        mul_b8 = y_hat_r[3][15:0];
                    end
                    4'd7: begin
                        H_w[2][2] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[3][2] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[0][3][15:0];
                        mul_b1 = y_hat_r[0][15:0];
                        mul_a2 = H_r[0][3][31:16];
                        mul_b2 = y_hat_r[0][31:16];
                        mul_a3 = H_r[0][3][15:0];
                        mul_b3 = y_hat_r[0][31:16];
                        mul_a4 = H_r[0][3][31:16];
                        mul_b4 = y_hat_r[0][15:0];

                        mul_a5 = H_r[1][3][15:0];
                        mul_b5 = y_hat_r[1][15:0];
                        mul_a6 = H_r[1][3][31:16];
                        mul_b6 = y_hat_r[1][31:16];
                        mul_a7 = H_r[1][3][15:0];
                        mul_b7 = y_hat_r[1][31:16];
                        mul_a8 = H_r[1][3][31:16];
                        mul_b8 = y_hat_r[1][15:0];
                    end
                    4'd8: begin
                        H_w[0][3] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[1][3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));

                        mul_a1 = H_r[2][3][15:0];
                        mul_b1 = y_hat_r[2][15:0];
                        mul_a2 = H_r[2][3][31:16];
                        mul_b2 = y_hat_r[2][31:16];
                        mul_a3 = H_r[2][3][15:0];
                        mul_b3 = y_hat_r[2][31:16];
                        mul_a4 = H_r[2][3][31:16];
                        mul_b4 = y_hat_r[2][15:0];

                        mul_a5 = H_r[3][3][15:0];
                        mul_b5 = y_hat_r[3][15:0];
                        mul_a6 = H_r[3][3][31:16];
                        mul_b6 = y_hat_r[3][31:16];
                        mul_a7 = H_r[3][3][15:0];
                        mul_b7 = y_hat_r[3][31:16];
                        mul_a8 = H_r[3][3][31:16];
                        mul_b8 = y_hat_r[3][15:0];
                    end
                    4'd9: begin
                        H_w[2][3] = ($signed(mul_c1[30:0]) + $signed(mul_c2[30:0])) + ($signed(mul_c5[30:0]) + $signed(mul_c6[30:0]));
                        H_w[3][3] = ($signed(mul_c3[30:0]) - $signed(mul_c4[30:0])) + ($signed(mul_c7[30:0]) - $signed(mul_c8[30:0]));
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
                        y_hat_w[0] = {temp7[32], temp7[12 +: 19], temp3[32], temp3[12 +: 19]};
                        y_hat_w[1] = {temp8[32], temp8[12 +: 19], temp4[32], temp4[12 +: 19]};
                        y_hat_w[2] = {temp9[32], temp9[12 +: 19], temp5[32], temp5[12 +: 19]};
                        y_hat_w[3] = {temp10[32], temp10[12 +: 19], temp6[32], temp6[12 +: 19]};
                        mul_iter_w = 0;
                        second_proc_counter_w = 0;
                        rd_vld_w = 1;
                        if (group_number_r == 9) begin
                            last_data_w = 1;
                        end
                    end
                    default: begin

                    end
                endcase
            end
        end
        default: begin

        end
    endcase
end


// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        state_r <= S_READ;

        y_hat_r[0] <= 0;
        y_hat_r[1] <= 0;
        y_hat_r[2] <= 0;
        y_hat_r[3] <= 0;

        r_r            <= 0;
        rd_vld_r       <= 0;
        last_data_r    <= 0;
        counter_r      <= 0;
        div_counter_r  <= 0;
        group_number_r <= 0;
        mul_iter_r     <= 0;
        sqrt_iter_r    <= 0;
        col_r          <= 1;
        row_r          <= 0;

        first_proc_counter_r  <= 0;
        second_proc_counter_r <= 0;
        address_counter_r     <= 0;
        sqrt_counter_r        <= 0;
        sqrt_en_r             <= 0;

        temp_result_r[0] <= 0;
        temp_result_r[1] <= 0;
        temp_result_r[2] <= 0;
        temp_result_r[3] <= 0;
        temp_result_r[4] <= 0;
        temp_result_r[5] <= 0;
        temp_result_r[6] <= 0;
        temp_result_r[7] <= 0;

        H_r[0][0] <= 0;
        H_r[0][1] <= 0;
        H_r[0][2] <= 0;
        H_r[0][3] <= 0;
        H_r[1][0] <= 0;
        H_r[1][1] <= 0;
        H_r[1][2] <= 0;
        H_r[1][3] <= 0;
        H_r[2][0] <= 0;
        H_r[2][1] <= 0;
        H_r[2][2] <= 0;
        H_r[2][3] <= 0;
        H_r[3][0] <= 0;
        H_r[3][1] <= 0;
        H_r[3][2] <= 0;
        H_r[3][3] <= 0;
    end
    else begin
        state_r <= state_w;
        y_hat_r[0] <= y_hat_w[0];
        y_hat_r[1] <= y_hat_w[1];
        y_hat_r[2] <= y_hat_w[2];
        y_hat_r[3] <= y_hat_w[3];

        r_r                   <= r_w;
        rd_vld_r              <= rd_vld_w;
        last_data_r           <= last_data_w;
        counter_r             <= counter_w;
        div_counter_r         <= div_counter_w;
        group_number_r        <= group_number_w;
        mul_iter_r            <= mul_iter_w;
        sqrt_iter_r           <= sqrt_iter_w;
        col_r                 <= col_w;
        row_r                 <= row_w;
        first_proc_counter_r  <= first_proc_counter_w;
        second_proc_counter_r <= second_proc_counter_w;
        address_counter_r     <= address_counter_w;
        sqrt_counter_r        <= sqrt_counter_w;
        sqrt_en_r             <= sqrt_en_w;
        for (i = 0; i < 8; i = i + 1) begin
            temp_result_r[i] <= temp_result_w[i];
        end
        temp_result_r[0] <= temp_result_w[0];
        temp_result_r[1] <= temp_result_w[1];
        temp_result_r[2] <= temp_result_w[2];
        temp_result_r[3] <= temp_result_w[3];
        temp_result_r[4] <= temp_result_w[4];
        temp_result_r[5] <= temp_result_w[5];
        temp_result_r[6] <= temp_result_w[6];
        temp_result_r[7] <= temp_result_w[7];

        H_r[0][0] <= H_w[0][0];
        H_r[0][1] <= H_w[0][1];
        H_r[0][2] <= H_w[0][2];
        H_r[0][3] <= H_w[0][3];
        H_r[1][0] <= H_w[1][0];
        H_r[1][1] <= H_w[1][1];
        H_r[1][2] <= H_w[1][2];
        H_r[1][3] <= H_w[1][3];
        H_r[2][0] <= H_w[2][0];
        H_r[2][1] <= H_w[2][1];
        H_r[2][2] <= H_w[2][2];
        H_r[2][3] <= H_w[2][3];
        H_r[3][0] <= H_w[3][0];
        H_r[3][1] <= H_w[3][1];
        H_r[3][2] <= H_w[3][2];
        H_r[3][3] <= H_w[3][3];
    end
end
endmodule
