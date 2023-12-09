// `timescale 1ns/1ps
`define CYCLE       10.0
`define RST_DELAY   2
`define MAX_CYCLE   100000

module testbed;
    
    parameter I_DATA_W  = 16;
    parameter O_DATA_W  = 16;

    // inout port
    reg                      i_clk;
    reg                      i_rst;
    wire  signed [I_DATA_W-1:0] i_data_a;
    wire  signed [I_DATA_W-1:0] i_data_b;
    wire signed [O_DATA_W-1:0] o_data;
    wire fin;
    assign i_data_a = -5066;
    assign i_data_b = 10028;
    // self defined
    
    // DW_sqrt_pipe_inst ab ( 
    //     .inst_clk(i_clk), 
    //     .inst_rst_n(i_rst_n), 
    //     .inst_en(1), 
    //     .inst_a(i_data_a), 
    //     .root_inst(o_data)
    // );
    // QR_Engine qr (
    //     .i_clk(i_clk),
    //     .i_rst(i_rst_n),
    //     .i_trig(1'b1),
    //     .i_data({i_data_a,i_data_b}),
    //     .o_y_hat(o_y)
    // );
    Divide divide (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .a(i_data_a),
        .b(i_data_b),
        .en(1'b1),
        .fin(fin),
        .result(o_data)
    );
    initial i_clk = 0;
    always #(`CYCLE/2.0) i_clk = ~i_clk; 

    initial begin
       $fsdbDumpfile("QR.fsdb");
       $fsdbDumpvars(0, testbed, "+mda");
    end

    initial begin
        i_rst  = 0;
        reset;
    end


    initial begin
            // $display("  Wrong! Total error: %d                      ", error);
        # (9 * `CYCLE);
        $display("result: ", $signed(o_data));
        $finish;
    end    

    initial begin
        # (`MAX_CYCLE * `CYCLE);
        $display("----------------------------------------------");
        $display("Latency of your design is over 100000 cycles!!");
        $display("----------------------------------------------");
        $finish;
    end

    task reset; begin
        # ( 0.25 * `CYCLE);
        i_rst = 1;    
        # ((`RST_DELAY) * `CYCLE);
        i_rst = 0;    
    end endtask

endmodule