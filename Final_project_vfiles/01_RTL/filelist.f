+v2k 
-debug_access+all 
+notimingcheck 
-P /usr/cad/synopsys/verdi/cur/share/PLI/VCS/LINUX64/novas.tab
/usr/cad/synopsys/verdi/cur/share/PLI/VCS/LINUX64/pli.a
-sverilog 
-assert svaext
+lint=TFIPC-L
+fsdb+parameter=on

-y /usr/cad/synopsys/synthesis/cur/dw/sim_ver +libext+.v
+incdir+/usr/cad/synopsys/synthesis/cur/dw/sim_ver/+

// Change different packets
+define+P6

// Add your RTL & SRAM files
../01_RTL/QR_Engine.v
../01_RTL/DW_sqrt_pipe_inst.v
../01_RTL/Div_LUT.v
../01_RTL/DW_mult_pipe_inst.v
../SRAM/sram_256x8/sram_256x8.v

// tb
../00_TESTBED/testfixture.v