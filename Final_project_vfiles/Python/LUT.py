LUT = []
outfile = open("LUT.txt", "w")

for i in range(128):
    print(round(1/(128+i)*(2**22)))
    # print(bin(round(1/(64+i)*(2**21)))[2:].zfill(16))
    if i == 0:
        LUT.append("0111111111111111")
    else:
        LUT.append(bin(round(1/(128+i)*(2**22)))[2:].zfill(16))

print(len(LUT))
for i in range(len(LUT)):
    # print(bin(i)[2:].zfill(6))
    outfile.write("7'b"+bin(i)[2:].zfill(7) + ": begin\n")
    outfile.write("    reciprocal = 16'b" + LUT[i] + ";\n")
    outfile.write("end\n")
