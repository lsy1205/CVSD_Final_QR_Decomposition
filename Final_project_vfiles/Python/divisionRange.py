import math 
import numpy as np

file1 = open('../01_RTL/PATTERN/packet_1/output_R.dat', 'r')
file2 = open('../01_RTL/PATTERN/packet_2/output_R.dat', 'r')
file3 = open('../01_RTL/PATTERN/packet_3/output_R.dat', 'r')
file4 = open('../01_RTL/PATTERN/packet_4/output_R.dat', 'r')
file5 = open('../01_RTL/PATTERN/packet_5/output_R.dat', 'r')
file6 = open('../01_RTL/PATTERN/packet_6/output_R.dat', 'r')
file_list = [file1, file2, file3, file4, file5, file6]

hfile1 = open('../01_RTL/PATTERN/packet_1/input_H_and_y.dat', 'r')
hfile2 = open('../01_RTL/PATTERN/packet_2/input_H_and_y.dat', 'r')
hfile3 = open('../01_RTL/PATTERN/packet_3/input_H_and_y.dat', 'r')
hfile4 = open('../01_RTL/PATTERN/packet_4/input_H_and_y.dat', 'r')
hfile5 = open('../01_RTL/PATTERN/packet_5/input_H_and_y.dat', 'r')
hfile6 = open('../01_RTL/PATTERN/packet_6/input_H_and_y.dat', 'r')

outf = open('output_R.txt', 'w')

def signed_bin_to_dec(signed_binary_string):
    if signed_binary_string[0] == '1':
        # Convert the negative binary string to its two's complement
        inverted_bits = ''.join('1' if bit == '0' else '0' for bit in signed_binary_string)
        signed_integer = -(int(inverted_bits, 2) + 1)
    else:
        # Convert the positive binary string to an integer
        signed_integer = int(signed_binary_string, 2)
    return signed_integer

RLIST = np.zeros(24000)
f = 0
i = 0

for file in file_list:
    for line in file: 
        clean_line = line.rstrip()
        # if i == 0:
        #     print(clean_line)
        #     print(clean_line[0:5])   # r44
        #     print(clean_line[35:40]) # r33
        #     print(clean_line[60:65]) # r22
        #     print(clean_line[75:80]) # r11
        #     print(bin(int(clean_line[0:5],16))[2:].zfill(20))
        #     print(bin(int(clean_line[35:40],16))[2:].zfill(20))
        #     print(bin(int(clean_line[60:65],16))[2:].zfill(20))
        #     print(bin(int(clean_line[75:80],16))[2:].zfill(20))
        RLIST[f*4000+i*4  ] = (int(clean_line[0:5],16))
        RLIST[f*4000+i*4+1] = (int(clean_line[35:40],16))
        RLIST[f*4000+i*4+2] = (int(clean_line[60:65],16))
        RLIST[f*4000+i*4+3] = (int(clean_line[75:80],16))
        i = i+1

RLIST= RLIST/(2**16)
# print(RLIST[0])
# print(RLIST[1])
# print(RLIST[2])
# print(RLIST[3])
# print(len(RLIST))
print("average: ", np.average(RLIST))
print("min:     ", np.min(RLIST))
print("max:     ", np.max(RLIST))    
print("std:     ", np.std(RLIST))

for x in range(len(RLIST)):
    outf.write(str(RLIST[x]) + '\n')

# checking h files
# print("=====================================")
# h1 = np.zeros((4,2))
# # print(h1)
# j = 0
# for line in hfile6:
#     clean_line = line.rstrip()
#     if j<20:
#         if j ==  0: 
#             # print(clean_line[0: 6])
#             # print(clean_line[6:12])
#             # print(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             # print(bin(int(clean_line[6:12],16))[2:].zfill(24))
#             h1[0][0] = signed_bin_to_dec(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             h1[0][1] = signed_bin_to_dec(bin(int(clean_line[6:12],16))[2:].zfill(24))
#         if j ==  5: 
#             # print(clean_line[0: 6])
#             # print(clean_line[6:12])
#             # print(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             # print(bin(int(clean_line[6:12],16))[2:].zfill(24))
#             h1[1][0] = signed_bin_to_dec(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             h1[1][1] = signed_bin_to_dec(bin(int(clean_line[6:12],16))[2:].zfill(24))
#         if j == 10: 
#             # print(clean_line[0: 6])
#             # print(clean_line[6:12])
#             # print(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             # print(bin(int(clean_line[6:12],16))[2:].zfill(24))
#             h1[2][0] = signed_bin_to_dec(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             h1[2][1] = signed_bin_to_dec(bin(int(clean_line[6:12],16))[2:].zfill(24))
#         if j == 15: 
#             # print(clean_line[0: 6])
#             # print(clean_line[6:12])
#             # print(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             # print(bin(int(clean_line[6:12],16))[2:].zfill(24))
#             h1[3][0] = signed_bin_to_dec(bin(int(clean_line[0: 6],16))[2:].zfill(24))
#             h1[3][1] = signed_bin_to_dec(bin(int(clean_line[6:12],16))[2:].zfill(24))
#     j = j+1

# h1 = h1/(2**22)
# # print(h1)
# print("=====================================")
# a = 0
# for i in range(4):
#     for j in range(2):
#         # print(h1[i][j]**2)
#         a = a + h1[i][j]**2
# # print(h1)
# print(a**0.5)