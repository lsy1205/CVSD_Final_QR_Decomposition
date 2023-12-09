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

// Memory Blocks
wire [7:0] Q [0:3];  // read data

reg [7:0] A   [0:3]; // input address
reg [7:0] D   [0:3]; // input data
reg       CEN [0:3]; // chip enable
// reg       WEN [0:3]; // write enable equal i_trig?

// Sqrt Blocks
reg sqrt_en;

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

// // Division
// Divide div0(
//     .i_clk(i_clk),
//     .i_rst(i_rst),
//     .a(a[15:0]), // change name
//     .b(b[15:0]), // change name
//     .en(),
//     .fin(div_fin), // change name
//     .result(temp1[15:0]) // change name
// );

// Multiplier
// Multiplier mul0(
//     .A(),
//     .B(),
//     .C()
// );

// Multiplier mul1(
//     .A(),
//     .B(),
//     .C()
// );
// Multiplier mul2(
//     .A(),
//     .B(),
//     .C()
// );
// Multiplier mul3(
//     .A(),
//     .B(),
//     .C()
// );
// Multiplier mul4(
//     .A(),
//     .B(),
//     .C()
// );
// Multiplier mul5(
//     .A(),
//     .B(),
//     .C()
// );
// // Square Root
// DW_sqrt_pipe_inst sqrt(
//     .inst_clk(i_clk),
//     .inst_rst_n(~i_rst),
//     .inst_en(sqrt_en),
//     .inst_a(),
//     .root_inst()
// );

// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
integer i;
// Finite State Machine
always @(*) begin
    state_w = state_r;
    case(state_r)
        S_READ: begin
            if (counter_r == 199) begin
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
    counter_w = counter_r;
    record_w = record_r;
    div_counter_w = div_counter_r;
    for (i = 0; i < 4; i = i + 1) begin
        CEN[i] = 1;
    end
    case(state_r)
        S_READ: begin
            if (i_trig) begin
                if (counter_r == 199) begin
                    counter_w = 0;
                end
                else begin
                    counter_w = counter_r + 1;
                end
                for (i = 0; i < 4; i = i + 1) begin
                    CEN[i] = 0;
                    A[i] = counter_r;
                end
                D[0] = i_data[47:40];
                D[1] = i_data[39:32];
                D[2] = i_data[23:16];
                D[3] = i_data[15:8];
            end
        end
        S_CALC: begin
            counter_w = counter_r + 1;
            rd_vld = 0;
            last_data = 0;
            if (counter_r == 200) begin
                record_w = record_r + 1;
                counter_w = 0;
                rd_vld = 1;
                if (record_r == 9) begin
                    last_data = 1;
                end
            end
            for (i = 0; i < 4; i = i + 1) begin
                CEN[i] = 0;
                A[i] = counter_r;
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
        counter_r <= 0;
        record_r  <= 0;
        div_counter_r <= 0;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        record_r <= record_w;
        div_counter_r <= div_counter_w;
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
