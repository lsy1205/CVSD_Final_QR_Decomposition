module DW02_mult_2_stage_inst( inst_a, inst_b, inst_tc, inst_clk, product_inst );
  parameter A_width = 16;
  parameter B_width = 16;
  input [A_width-1 : 0] inst_a;
  input [B_width-1 : 0] inst_b;
  input inst_tc;  
  input inst_clk;  
  output [A_width+B_width-1 : 0] product_inst;
  // Instance of DW02_mult_2_stage 
   DW02_mult_2_stage #(A_width, B_width)
      U1 ( .A(inst_a),   
           .B(inst_b),   
           .TC(inst_tc), 
           .CLK(inst_clk),   
           .PRODUCT(product_inst) );
endmodule