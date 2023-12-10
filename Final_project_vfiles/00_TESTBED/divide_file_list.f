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
+define+P1

// Add your RTL & SRAM files
../01_RTL/Divide.v

// tb
divide_tb.v
