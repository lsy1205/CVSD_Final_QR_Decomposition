import math 
import numpy as np

R_file1 = open('../01_RTL/PATTERN/packet_1/output_R.dat', 'r')
R_file2 = open('../01_RTL/PATTERN/packet_2/output_R.dat', 'r')
R_file3 = open('../01_RTL/PATTERN/packet_3/output_R.dat', 'r')
R_file4 = open('../01_RTL/PATTERN/packet_4/output_R.dat', 'r')
R_file5 = open('../01_RTL/PATTERN/packet_5/output_R.dat', 'r')
R_file6 = open('../01_RTL/PATTERN/packet_6/output_R.dat', 'r')
R_file_list = [R_file1, R_file2, R_file3, R_file4, R_file5, R_file6]

file1 = open('../01_RTL/PATTERN/packet_1/input_H_and_y.dat', 'r')
file2 = open('../01_RTL/PATTERN/packet_2/input_H_and_y.dat', 'r')
file3 = open('../01_RTL/PATTERN/packet_3/input_H_and_y.dat', 'r')
file4 = open('../01_RTL/PATTERN/packet_4/input_H_and_y.dat', 'r')
file5 = open('../01_RTL/PATTERN/packet_5/input_H_and_y.dat', 'r')
file6 = open('../01_RTL/PATTERN/packet_6/input_H_and_y.dat', 'r')
file_list = [file1, file2, file3, file4, file5, file6]


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

YLIST = np.zeros(48000, int)
HLIST = np.zeros(192000, int)
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
