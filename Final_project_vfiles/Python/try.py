import numpy as np
H_2d_array = np.zeros((4, 4), dtype = list)
y_array = np.zeros((4, 1), dtype = list)

def bin_to_int(signed_binary_string):
    if signed_binary_string[0] == '1':
        # Convert the negative binary string to its two's complement
        inverted_bits = ''.join('1' if bit == '0' else '0' for bit in signed_binary_string)
        signed_integer = -(int(inverted_bits, 2) + 1)
    else:
        # Convert the positive binary string to an integer
        signed_integer = int(signed_binary_string, 2)
    return signed_integer

with open('../01_RTL/PATTERN/packet_1/input_H_and_y.dat', 'r') as file:
    # Read file line by line
    i = 0
    temp = 0
    for line in file:
        clean_line = line.rstrip()
        binary = bin(int(clean_line, 16))[2:].zfill(len(clean_line) * 4)
        if i == 0: 
            print(binary)
            print(binary[0:24])
            print(binary[24:48])
        if i % 20 == 0: H_2d_array[0][0] = binary
        if i % 20 == 1: H_2d_array[0][1] = binary
        if i % 20 == 2: H_2d_array[0][2] = binary
        if i % 20 == 3: H_2d_array[0][3] = binary
        if i % 20 == 4: y_array[0] = binary
        if i % 20 == 5: H_2d_array[1][0] = binary
        if i % 20 == 6: H_2d_array[1][1] = binary
        if i % 20 == 7: H_2d_array[1][2] = binary
        if i % 20 == 8: H_2d_array[1][3] = binary
        if i % 20 == 9: y_array[1] = binary
        if i % 20 == 10: H_2d_array[2][0] = binary
        if i % 20 == 11: H_2d_array[2][1] = binary
        if i % 20 == 12: H_2d_array[2][2] = binary
        if i % 20 == 13: H_2d_array[2][3] = binary
        if i % 20 == 14: y_array[2] = binary
        if i % 20 == 15: H_2d_array[3][0] = binary
        if i % 20 == 16: H_2d_array[3][1] = binary
        if i % 20 == 17: H_2d_array[3][2] = binary
        if i % 20 == 18: H_2d_array[3][3] = binary
        if i % 20 == 19: y_array[3] = binary

        i += 1

        if i == 20: break

print((H_2d_array[0][0][0:24]))
print(bin_to_int(H_2d_array[0][0][0:24])/2 ** 22)
print(bin_to_int(H_2d_array[0][0][24:48])/2 ** 22)
