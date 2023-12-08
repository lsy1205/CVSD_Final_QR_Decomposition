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
localparam S_IDLE = 0;
localparam S_READ = 1;  // 200 cycles
localparam S_CALC = 2;  // process * 9


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

// Memory Blocks
wire [7:0] Q [0:3];  // read data

reg [7:0] A   [0:3]; // input address
reg [7:0] D   [0:3]; // input data
reg       CEN [0:3]; // chip enable
reg       WEN [0:3]; // write enable

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
    .WEN(WEN[0]),
    .A(A[0]),
    .D(D[0])
);

sram_256x8 mem1(
    .Q(Q[1]),
    .CLK(i_clk),
    .CEN(CEN[1]),
    .WEN(WEN[1]),
    .A(A[1]),
    .D(D[1])
);

sram_256x8 mem2(
    .Q(Q[2]),
    .CLK(i_clk),
    .CEN(CEN[2]),
    .WEN(WEN[2]),
    .A(A[2]),
    .D(D[2])
);

sram_256x8 mem3(
    .Q(Q[3]),
    .CLK(i_clk),
    .CEN(CEN[3]),
    .WEN(WEN[3]),
    .A(A[3]),
    .D(D[3])
);

// Division
Divide div0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .a({temp_a[18:0], 8'b0}), // change name
    .b({3'b0, temp3_r[15:0], 8'b0}), // change name
    .en(),
    .fin(div_fin), // change name
    .result(temp1[15:0]) // change name
);

// Multiplier
Multiplier mul0(
    .A(),
    .B(),
    .C()
);

Multiplier mul1(
    .A(),
    .B(),
    .C()
);
Multiplier mul2(
    .A(),
    .B(),
    .C()
);
Multiplier mul3(
    .A(),
    .B(),
    .C()
);
Multiplier mul4(
    .A(),
    .B(),
    .C()
);
Multiplier mul5(
    .A(),
    .B(),
    .C()
);
// Square Root


// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// Finite State Machine
always @(*) begin
    
end

// Logic
always @(*) begin
    
end


// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        
    end
    else begin

    end
end
endmodule

module Multiplier (
    input  [15:0] A,
    input  [15:0] B,
    output [19:0] C
); // bit number of C is incorrect, should adjust with square root
    assign C = temp[19:0];
    reg [31:0] temp;
    always @(*) begin
        temp = $signed(A) * $signed(B);
    end 
endmodule
