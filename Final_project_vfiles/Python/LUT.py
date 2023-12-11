LUT = []
outfile = open("LUT.txt", "w")

for i in range(32):
    # print(round(1/(64+i)*(2**21)))
    # print(bin(round(1/(64+i)*(2**21)))[2:].zfill(16))
    if i == 0:
        LUT.append("0111111111111111")
    else:
        LUT.append(bin(round(1/(64+i)*(2**21)))[2:].zfill(16))

for i in range(len(LUT)):
    print(bin(i)[2:].zfill(5))
    outfile.write("5'b"+bin(i)[2:].zfill(5) + ": begin\n")
    outfile.write("    reciprocal = 16'b" + LUT[i] + ";\n")
    outfile.write("end\n")
