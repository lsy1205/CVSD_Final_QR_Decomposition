import math 
import numpy as np

file1 = open('../01_RTL/PATTERN/packet_1/input_H_and_y.dat', 'r')
file2 = open('../01_RTL/PATTERN/packet_2/input_H_and_y.dat', 'r')
file3 = open('../01_RTL/PATTERN/packet_3/input_H_and_y.dat', 'r')
file4 = open('../01_RTL/PATTERN/packet_4/input_H_and_y.dat', 'r')
file5 = open('../01_RTL/PATTERN/packet_5/input_H_and_y.dat', 'r')
file6 = open('../01_RTL/PATTERN/packet_6/input_H_and_y.dat', 'r')
file11 = open('../01_RTL/Extra_Pattern/SNR10/E1/input_H_and_y.dat' , 'r')
file12 = open('../01_RTL/Extra_Pattern/SNR10/E2/input_H_and_y.dat' , 'r')
file13 = open('../01_RTL/Extra_Pattern/SNR10/E3/input_H_and_y.dat' , 'r')
file14 = open('../01_RTL/Extra_Pattern/SNR10/E4/input_H_and_y.dat' , 'r')
file15 = open('../01_RTL/Extra_Pattern/SNR10/E5/input_H_and_y.dat' , 'r')
file16 = open('../01_RTL/Extra_Pattern/SNR10/E6/input_H_and_y.dat' , 'r')
file17 = open('../01_RTL/Extra_Pattern/SNR10/E7/input_H_and_y.dat' , 'r')
file18 = open('../01_RTL/Extra_Pattern/SNR10/E8/input_H_and_y.dat' , 'r')
file19 = open('../01_RTL/Extra_Pattern/SNR10/E9/input_H_and_y.dat' , 'r')
file20 = open('../01_RTL/Extra_Pattern/SNR10/E10/input_H_and_y.dat', 'r')
file21 = open('../01_RTL/Extra_Pattern/SNR15/E1/input_H_and_y.dat' , 'r')
file22 = open('../01_RTL/Extra_Pattern/SNR15/E2/input_H_and_y.dat' , 'r')
file23 = open('../01_RTL/Extra_Pattern/SNR15/E3/input_H_and_y.dat' , 'r')
file24 = open('../01_RTL/Extra_Pattern/SNR15/E4/input_H_and_y.dat' , 'r')
file25 = open('../01_RTL/Extra_Pattern/SNR15/E5/input_H_and_y.dat' , 'r')
file26 = open('../01_RTL/Extra_Pattern/SNR15/E6/input_H_and_y.dat' , 'r')
file27 = open('../01_RTL/Extra_Pattern/SNR15/E7/input_H_and_y.dat' , 'r')
file28 = open('../01_RTL/Extra_Pattern/SNR15/E8/input_H_and_y.dat' , 'r')
file29 = open('../01_RTL/Extra_Pattern/SNR15/E9/input_H_and_y.dat' , 'r')
file30 = open('../01_RTL/Extra_Pattern/SNR15/E10/input_H_and_y.dat', 'r')
file_list = [file25]


outf = open('all_y.txt', 'w')
outf2 = open('all_H.txt', 'w')

def signed_bin_to_dec(signed_binary_string):
    if signed_binary_string[0] == '1':
        # Convert the negative binary string to its two's complement
        inverted_bits = ''.join('1' if bit == '0' else '0' for bit in signed_binary_string)
        signed_integer = -(int(inverted_bits, 2) + 1)
    else:
        # Convert the positive binary string to an integer
        signed_integer = int(signed_binary_string, 2)
    return signed_integer

YLIST = np.zeros(len(file_list)*8000, int)
HLIST = np.zeros(len(file_list)*32000, int)
f_num = 0
i = 0

for file in file_list:
    for line in file:
        clean_line = line.rstrip()
        if (i%5) == 4:
            # print(clean_line)
            # print(bin(int(clean_line[0:6], 16))[2:].zfill(24))
            im = signed_bin_to_dec(bin(int(clean_line[0:6], 16))[2:].zfill(24))
            # print(bin(int(clean_line[6:12], 16))[2:].zfill(24))
            re = signed_bin_to_dec(bin(int(clean_line[6:12], 16))[2:].zfill(24))
            YLIST[f_num*8000+(i//5)*2  ] = im
            YLIST[f_num*8000+(i//5)*2+1] = re
        else: 
            im = signed_bin_to_dec(bin(int(clean_line[0:6], 16))[2:].zfill(24))
            re = signed_bin_to_dec(bin(int(clean_line[6:12], 16))[2:].zfill(24))
            HLIST[f_num*32000+i*2  -(i//5)*2] = im
            HLIST[f_num*32000+i*2+1-(i//5)*2] = re
        i = i + 1
    i = 0
    f_num = f_num + 1


YLIST = YLIST/(2**22)
for x in range(len(YLIST)):
    outf.write(str(YLIST[x]) + '\n')

HLIST = HLIST/(2**22)
for x in range (len(HLIST)):
    outf2.write(str(HLIST[x]) + '\n')

print("y average: ", np.average(YLIST))
print("y min:     ", np.min(YLIST))
print("y max:     ", np.max(YLIST))
print("y std:     ", np.std(YLIST))

print("==================================")
print("h average: ", np.average(HLIST))
print("h min:     ", np.min(HLIST))
print("h max:     ", np.max(HLIST))
print("h std:     ", np.std(HLIST))
