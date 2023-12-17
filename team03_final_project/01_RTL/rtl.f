// -----------------------------------------------------------------------------
// Simulation: Final_QR_Engine
// -----------------------------------------------------------------------------

// testbench
// -----------------------------------------------------------------------------
./testfixture.v

// design files
// -----------------------------------------------------------------------------
// Add your RTL & SRAM files
../01_RTL/QR_Engine.v
../01_RTL/DW_sqrt_pipe_inst.v
../01_RTL/Div_LUT.v
../01_RTL/DW_mult_pipe_inst.v

// SRAM.v
../SRAM/sram_256x8/sram_256x8.v
/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13_neg.v
