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
reg         rd_vld;
reg         last_data;
reg [159:0] y_hat_w, y_hat_r;
reg [319:0] r_w, r_r;

// Control
reg [1:0] state_w, state_r;
reg [7:0] counter_w, counter_r;
reg [3:0] record_w, record_r;
reg [2:0] div_counter_w, div_counter_r;
reg [2:0] sqrt_counter_w, sqrt_counter_r;
reg [2:0] first_proc_counter_w, first_proc_counter_r;
reg [5:0] second_proc_counter_w, second_proc_counter_r;
reg [1:0] iter_w, iter_r;
reg [4:0] address_counter_w, address_counter_r;

// Memory Blocks
wire [7:0] Q [0:3];  // read data
reg [7:0] A   [0:3]; // input address
reg [7:0] D   [0:3]; // input data
reg       CEN [0:3]; // chip enable
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
reg [15:0] div_a;
reg [15:0] div_b;
reg  div_en_w, div_en_r;
wire div_fin;
wire [15:0] div_result;


//usual store register
reg [31:0] H_w [0:3][0:3], H_r [0:3][0:3];
reg [31:0] temp_result_w [0:7], temp_result_r [0:7];
reg [3:0] group_number_w, group_number_r;
reg [2:0] col_w, col_r;
reg [1:0] row_w, row_r;
reg [33:0] temp;
reg [33:0] temp2;

// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// IO
assign o_rd_vld    = rd_vld;
assign o_last_data = last_data;
assign o_y_hat     = y_hat_r;
assign o_r         = r_r;


// ---------------------------------------------------------------------------
// Macro Instantiate
// ---------------------------------------------------------------------------

// Memory
sram_256x8 mem0(
    .Q(Q[0]),
    .CLK(i_clk),
    .CEN(CEN[0]),
    // .WEN(WEN[0]),
    .WEN(~i_trig),
    .A(A[0]),
    .D(D[0]) // image high 8bit
);

sram_256x8 mem1(
    .Q(Q[1]),
    .CLK(i_clk),
    .CEN(CEN[1]),
    // .WEN(WEN[1]),
    .WEN(~i_trig),
    .A(A[1]),
    .D(D[1]) // image low 8bit
);

sram_256x8 mem2(
    .Q(Q[2]),
    .CLK(i_clk),
    .CEN(CEN[2]),
    // .WEN(WEN[2]),
    .WEN(~i_trig),
    .A(A[2]),
    .D(D[2]) // real high 8bit
);

sram_256x8 mem3(
    .Q(Q[3]),
    .CLK(i_clk),
    .CEN(CEN[3]),
    // .WEN(WEN[3]),
    .WEN(~i_trig),
    .A(A[3]),
    .D(D[3]) // real low 8bit
);

// Division
Divide div0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .a(div_a[15:0]), // change name
    .b(div_b[15:0]), // change name
    .en(div_en_r),
    .fin(div_fin), // change name
    .result(div_result) // change name
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
            if (last_data) begin
                state_w = S_READ;
            end
        end
    endcase
end

// Logic
always @(*) begin
    //data IO
    y_hat_w = y_hat_r;
    r_w = r_r;
    rd_vld = 0;
    last_data = 0;
    //sram write
    row_w = row_r;
    col_w = col_r;
    counter_w = counter_r;
    //process
    first_proc_counter_w = first_proc_counter_r;
    second_proc_counter_w = second_proc_counter_r;
    group_number_w = group_number_r;
    iter_w = iter_r;
    //div control
    div_counter_w = div_counter_r;
    div_a = 0;
    div_b = 0;
    div_en_w = 0;
    //sqrt control
    sqrt_counter_w = sqrt_counter_r;
    sqrt_en_w = 0;
    sqrt_a = 0;
    //sram read
    address_counter_w = address_counter_r;
    for (i = 0; i < 4; i = i + 1) begin
        CEN[i] = 1;
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

                for (i = 0; i < 4; i = i + 1) begin
                    CEN[i] = 0;
                    A[i] = counter_r;
                end
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
            first_proc_counter_w = first_proc_counter_r + 1;
            second_proc_counter_w = second_proc_counter_r + 1;

            // reset signal
            if (rd_vld == 1) begin
                address_counter_w = 0;
                first_proc_counter_w = 0;
                group_number_w = group_number_r + 1;
            end
            if (last_data) begin
                group_number_w = 0;
            end
            // end reset signal
            
            // Sram access
            if (address_counter_r != 16) begin
                if (first_proc_counter_r != 0) begin
                    H_w[address_counter_r[1:0]][address_counter_r[3:2]] = {Q[0],Q[1],Q[2],Q[3]};
                    address_counter_w = address_counter_r + 1;
                    for (i = 0; i < 4; i = i + 1) begin
                        A[i] = {group_number_r, address_counter_r+1};
                    end    
                end 
                else begin
                    for (i = 0; i < 4; i = i + 1) begin
                        A[i] = {group_number_r, 4'b0};
                    end 
                end

                for (i = 0; i < 4; i = i + 1) begin
                    CEN[i] = 0;
                end
            end
            // end Sram access

            // sqrt control
            if (sqrt_counter_r != 0 && sqrt_counter_r != 4) begin
                sqrt_en_w = 1;
                sqrt_counter_w = sqrt_counter_r + 1;
            end
            if (sqrt_counter_r == 4) begin
                sqrt_counter_w = 0;
                div_en_w = 1;
                div_counter_w = 1;
            end
            if (sqrt_counter_r == 1) begin
                sqrt_a = {1'b0, temp_result_r[0]};
            end
            // end sqrt control

            // divide control
            if (div_counter_r == 1) begin
                //different iteration is different
                if (iter_r == 0) begin
                    r_w[19:2] = sqrt_result;
                end
                else if (iter_r == 1) begin
                    r_w[79:62] = sqrt_result;
                end
                else if (iter_r == 2) begin
                    r_w[179:162] = sqrt_result;
                end
                else if (iter_r == 3) begin
                    r_w[319:302] = sqrt_result;
                end
            end
            if (div_counter_r != 0 && div_counter_r != 24) begin
                div_en_w = 1;
                div_counter_w = div_counter_r + 1;
            end

            if (div_counter_r == 24) begin
                div_counter_w = 0;
                second_proc_counter_w = 1;
            end
            // iteration 0, the result will store in y_hat_r[159:32]
            

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
                    temp_result_w[0] = temp[31:0];
                    sqrt_en_w = 1;
                    sqrt_counter_w = 1;
                end
            endcase
            
            // complex mul 
            // r = c(a+b) - b(c+d)
            // i = c(a+b) + a(d-c)
            if (iter_r == 0) begin
                case (second_proc_counter_r)
                    6'd1: begin
                        // a = y_hat_r[143:128]  b = y_hat_r[159:144]  c = H_r[0][1][15:0]  d = H_r[0][1][31:16]
                        mul_a1 = $signed(y_hat_r[143:128]) + $signed(y_hat_r[159:144]); //Q11 = y_hat_r[159:128] 
                        mul_b1 = H_r[0][1][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][1][15:0]) + $signed(H_r[0][1][31:16]);
                        mul_b2 = y_hat_r[159:144];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][1][31:16]) - $signed(H_r[0][1][15:0]);
                        mul_b3 = y_hat_r[143:128];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[111:96]  b = y_hat_r[127:112]  c = H_r[1][1][15:0]  d = H_r[1][1][31:16]
                        mul_a4 = $signed(y_hat_r[111:96]) + $signed(y_hat_r[127:112]); //Q12 = y_hat_r[127:96] 
                        mul_b4 = H_r[1][1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][1][15:0]) + $signed(H_r[1][1][31:16]);
                        mul_b5 = y_hat_r[127:112];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][1][31:16]) - $signed(H_r[1][1][15:0]);
                        mul_b6 = y_hat_r[111:96];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd2: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = y_hat_r[79:64]  b = y_hat_r[95:80]  c = H_r[2][1][15:0]  d = H_r[2][1][31:16]
                        mul_a1 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[95:80]); //Q13 = y_hat_r[95:64] 
                        mul_b1 = H_r[2][1][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][1][15:0]) + $signed(H_r[2][1][31:16]);
                        mul_b2 = y_hat_r[95:80];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][1][31:16]) - $signed(H_r[2][1][15:0]);
                        mul_b3 = y_hat_r[79:64];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[47:32]  b = y_hat_r[63:48]  c = H_r[3][1][15:0]  d = H_r[3][1][31:16]
                        mul_a4 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[63:48]); //Q14 = y_hat_r[63:32] 
                        mul_b4 = H_r[3][1][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][1][15:0]) + $signed(H_r[3][1][31:16]);
                        mul_b5 = y_hat_r[63:48];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][1][31:16]) - $signed(H_r[3][1][15:0]);
                        mul_b6 = y_hat_r[47:32];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd3: begin
                        temp = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[59:40] = {temp2[33],temp2[30:12]}; // R12
                        r_w[39:20] = {temp[33],temp[30:12]};

                        // a = y_hat_r[143:128]  b = y_hat_r[159:144]  c = H_r[0][2][15:0]  d = H_r[0][2][31:16]
                        mul_a1 = $signed(y_hat_r[143:128]) + $signed(y_hat_r[159:144]); //Q11 = y_hat_r[159:128] 
                        mul_b1 = H_r[0][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][2][15:0]) + $signed(H_r[0][2][31:16]);
                        mul_b2 = y_hat_r[159:144];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][2][31:16]) - $signed(H_r[0][2][15:0]);
                        mul_b3 = y_hat_r[143:128];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[111:96]  b = y_hat_r[127:112]  c = H_r[1][2][15:0]  d = H_r[1][2][31:16]
                        mul_a4 = $signed(y_hat_r[111:96]) + $signed(y_hat_r[127:112]); //Q12 = y_hat_r[127:96] 
                        mul_b4 = H_r[1][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][2][15:0]) + $signed(H_r[1][2][31:16]);
                        mul_b5 = y_hat_r[127:112];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][2][31:16]) - $signed(H_r[1][2][15:0]);
                        mul_b6 = y_hat_r[111:96];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd4: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = y_hat_r[79:64]  b = y_hat_r[95:80]  c = H_r[2][2][15:0]  d = H_r[2][2][31:16]
                        mul_a1 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[95:80]); //Q13 = y_hat_r[95:64] 
                        mul_b1 = H_r[2][2][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][2][15:0]) + $signed(H_r[2][2][31:16]);
                        mul_b2 = y_hat_r[95:80];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][2][31:16]) - $signed(H_r[2][2][15:0]);
                        mul_b3 = y_hat_r[79:64];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[47:32]  b = y_hat_r[63:48]  c = H_r[3][2][15:0]  d = H_r[3][2][31:16]
                        mul_a4 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[63:48]); //Q14 = y_hat_r[63:32] 
                        mul_b4 = H_r[3][2][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][2][15:0]) + $signed(H_r[3][2][31:16]);
                        mul_b5 = y_hat_r[63:48];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][2][31:16]) - $signed(H_r[3][2][15:0]);
                        mul_b6 = y_hat_r[47:32];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd5: begin
                        temp = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[119:100] = {temp2[33],temp2[30:12]}; // R13
                        r_w[99:80] = {temp[33],temp[30:12]};

                        // a = y_hat_r[143:128]  b = y_hat_r[159:144]  c = H_r[0][3][15:0]  d = H_r[0][3][31:16]
                        mul_a1 = $signed(y_hat_r[143:128]) + $signed(y_hat_r[159:144]); //Q11 = y_hat_r[159:128] 
                        mul_b1 = H_r[0][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[0][3][15:0]) + $signed(H_r[0][3][31:16]);
                        mul_b2 = y_hat_r[159:144];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[0][3][31:16]) - $signed(H_r[0][3][15:0]);
                        mul_b3 = y_hat_r[143:128];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[111:96]  b = y_hat_r[127:112]  c = H_r[1][3][15:0]  d = H_r[1][3][31:16]
                        mul_a4 = $signed(y_hat_r[111:96]) + $signed(y_hat_r[127:112]); //Q12 = y_hat_r[127:96] 
                        mul_b4 = H_r[1][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[1][3][15:0]) + $signed(H_r[1][3][31:16]);
                        mul_b5 = y_hat_r[127:112];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[1][3][31:16]) - $signed(H_r[1][3][15:0]);
                        mul_b6 = y_hat_r[111:96];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd6: begin
                        temp_result_w[6] = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4]));
                        temp_result_w[7] = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5]));

                        // a = y_hat_r[79:64]  b = y_hat_r[95:80]  c = H_r[2][3][15:0]  d = H_r[2][3][31:16]
                        mul_a1 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[95:80]); //Q13 = y_hat_r[95:64] 
                        mul_b1 = H_r[2][3][15:0];
                        temp_result_w[0] = mul_c1;
                        mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        mul_b2 = y_hat_r[95:80];
                        temp_result_w[1] = mul_c2;
                        mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        mul_b3 = y_hat_r[79:64];
                        temp_result_w[2] = mul_c3;
                        // a = y_hat_r[47:32]  b = y_hat_r[63:48]  c = H_r[3][3][15:0]  d = H_r[3][3][31:16]
                        mul_a4 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[63:48]); //Q14 = y_hat_r[63:32] 
                        mul_b4 = H_r[3][3][15:0];
                        temp_result_w[3] = mul_c4;
                        mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        mul_b5 = y_hat_r[63:48];
                        temp_result_w[4] = mul_c5;
                        mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        mul_b6 = y_hat_r[47:32];
                        temp_result_w[5] = mul_c6;
                    end
                    6'd7: begin
                        temp = ($signed(temp_result_r[0]) - $signed(temp_result_r[1])) + ($signed(temp_result_r[3]) - $signed(temp_result_r[4])) + $signed(temp_result_r[6]);
                        temp2 = ($signed(temp_result_r[0]) + $signed(temp_result_r[2])) + ($signed(temp_result_r[3]) + $signed(temp_result_r[5])) + $signed(temp_result_r[7]);
                        r_w[219:200] = {temp2[33],temp2[30:12]}; //R14
                        r_w[199:180] = {temp[33],temp[30:12]};

                        // a = y_hat_r[79:64]  b = y_hat_r[95:80]  c = H_r[2][3][15:0]  d = H_r[2][3][31:16]
                        // mul_a1 = $signed(r_r[59:40]) + $signed(y_hat_r[95:80]); //Q13 = y_hat_r[95:64] 
                        // mul_b1 = H_r[2][3][15:0];
                        // temp_result_w[0] = mul_c1;
                        // mul_a2 = $signed(H_r[2][3][15:0]) + $signed(H_r[2][3][31:16]);
                        // mul_b2 = y_hat_r[95:80];
                        // temp_result_w[1] = mul_c2;
                        // mul_a3 = $signed(H_r[2][3][31:16]) - $signed(H_r[2][3][15:0]);
                        // mul_b3 = y_hat_r[79:64];
                        // temp_result_w[2] = mul_c3;

                        // mul_a4 = $signed(y_hat_r[79:64]) + $signed(y_hat_r[63:48]); //Q14 = y_hat_r[63:32] 
                        // mul_b4 = H_r[3][3][15:0];
                        // temp_result_w[3] = mul_c4;
                        // mul_a5 = $signed(H_r[3][3][15:0]) + $signed(H_r[3][3][31:16]);
                        // mul_b5 = y_hat_r[63:48];
                        // temp_result_w[4] = mul_c5;
                        // mul_a6 = $signed(H_r[3][3][31:16]) - $signed(H_r[3][3][15:0]);
                        // mul_b6 = y_hat_r[47:32];
                        // temp_result_w[5] = mul_c6;
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
        y_hat_r <= 0;
        r_r     <= 0;
        counter_r <= 0;
        record_r  <= 0;
        div_counter_r <= 0;
        group_number_r <= 0;
        iter_r    <= 0;
        col_r     <= 1;
        row_r     <= 0;
        first_proc_counter_r <= 0;
        second_proc_counter_r <= 0;
        address_counter_r <= 0;
        sqrt_counter_r <= 0;
        sqrt_en_r <= 0;
        div_en_r  <= 0;
        for (i = 0; i < 8; i = i + 1) begin
            temp_result_r[i] <= 0;
            for (j = 0; j < 4; j = j + 1) begin
                H_r[i][j] <= 0;
            end
        end
    end
    else begin
        state_r <= state_w;
        y_hat_r <= y_hat_w;
        r_r     <= r_w;
        counter_r <= counter_w;
        record_r <= record_w;
        div_counter_r <= div_counter_w;
        group_number_r <= group_number_w;
        iter_r    <= iter_w;
        col_r    <= col_w;
        row_r    <= row_w;
        first_proc_counter_r <= first_proc_counter_w;
        second_proc_counter_r <= second_proc_counter_w;
        address_counter_r <= address_counter_w;
        sqrt_counter_r <= sqrt_counter_w;
        sqrt_en_r <= sqrt_en_w;
        div_en_r  <= div_en_w;
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
