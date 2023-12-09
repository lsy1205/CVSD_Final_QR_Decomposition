import numpy as np
import sys
import math

iter = 19
reserve = 23
def int_to_bin(number):
    if number < 0:
        temp = '0' + bin(number + 1)[3:]
        binary_string = ''.join('1' if bit == '0' else '0' for bit in temp)
    else:
        binary_string = '0' + bin(number)[2:]
    return binary_string

def Q_format(string, length):
    if string == '': return '0'*length
    if string[0] == '1':
        a = '1' * (length - len(string)) + string
    else:
        a = string.zfill(length)
    return a

def R_format(string, signed, length):
    if signed:
        a = '1' + string
    else:
        a = '0' + string
    zeros_need = length - len(a)
    return (a + '0' * zeros_need)

def binary_abs(signed_binary_string):
    if signed_binary_string[0] == '1':
        # Convert the negative binary string to its two's complement
        inverted_bits = ''.join('1' if bit == '0' else '0' for bit in signed_binary_string)
        signed_integer = -(int(inverted_bits, 2) + 1)
    else:
        # Convert the positive binary string to an integer
        signed_integer = int(signed_binary_string, 2)
    return signed_integer

def sqrt_approximate(number, iteration = iter):
    result = ""
    div = 1
    temp = number[0:2]
    for i in range(iteration):
        # print("iter:", i)
        if int(temp,2) < div:
            result += "0"
            temp += number[2*(i+1):2*(i+1)+2]
            # print("  temp1:" + temp)
        else:
            temp_result = int(temp,2) - div
            temp = bin(temp_result)[2:] + number[2*(i+1):2*(i+1)+2]
            # print("  temp2:" + temp)
            result += "1"
        div = (int(result,2) << 2) + 1
        # print("result:"+result)
        # print("div:", bin(div)[2:])
        
    return result



R_2d_array = [['' for _ in range(4)] for _ in range(4)]
Q_2d_array = [['' for _ in range(4)] for _ in range(4)]
H_2d_array = [['' for _ in range(4)] for _ in range(4)]
y_array = ['' for _ in range(4)]
y_hat_array = ['' for _ in range(4)]

with open('..\Matlab\Result\out_y_hat_SNR10_P3_result.txt', 'w') as file_2:
    with open('..\Matlab\Result\out_R_SNR10_P3_result.txt', 'w') as file_1:
        # Open the file in read mode ('r')
        with open('../01_RTL/PATTERN/packet_3/input_H_and_y.dat', 'r') as file:
            # Read file line by line
            i = 0
            temp = 0
            for line in file:
                clean_line = line.rstrip()
                binary = bin(int(clean_line, 16))[2:].zfill(len(clean_line) * 4)
                if i % 20 == 0: H_2d_array[0][0] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 1: H_2d_array[0][1] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 2: H_2d_array[0][2] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 3: H_2d_array[0][3] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 4: y_array[0] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 5: H_2d_array[1][0] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 6: H_2d_array[1][1] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 7: H_2d_array[1][2] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 8: H_2d_array[1][3] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 9: y_array[1] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 10: H_2d_array[2][0] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 11: H_2d_array[2][1] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 12: H_2d_array[2][2] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 13: H_2d_array[2][3] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 14: y_array[2] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 15: H_2d_array[3][0] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 16: H_2d_array[3][1] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 17: H_2d_array[3][2] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 18: H_2d_array[3][3] = binary[:reserve] + binary[24:(24+reserve)]
                if i % 20 == 19: y_array[3] = binary[:reserve] + binary[24:(24+reserve)]

                i = i + 1
                
                if i % 20 == 0 and i != 0: 

                    #iteration 1
                    #calculate Euclidean distance
                    a_1 = binary_abs(H_2d_array[0][0][0:reserve]) ** 2
                    a_2 = binary_abs(H_2d_array[0][0][reserve:2*reserve]) ** 2
                    a_3 = binary_abs(H_2d_array[1][0][0:reserve]) ** 2
                    a_4 = binary_abs(H_2d_array[1][0][reserve:2*reserve]) ** 2
                    a_5 = binary_abs(H_2d_array[2][0][0:reserve]) ** 2
                    a_6 = binary_abs(H_2d_array[2][0][reserve:2*reserve]) ** 2
                    a_7 = binary_abs(H_2d_array[3][0][0:reserve]) ** 2
                    a_8 = binary_abs(H_2d_array[3][0][reserve:2*reserve]) ** 2
                    temp = a_1 + a_2 + a_3 + a_4 + a_5 + a_6 + a_7 + a_8
                    # R_2d_array[0][0] = R_format(sqrt_approximate(bin(temp)[2:].zfill(50)),0,20)
                    R_2d_array[0][0] = Q_format(int_to_bin(int(math.sqrt(temp) / 2**(reserve - 18))),20)
                    
                    print("H: ", binary_abs(H_2d_array[0][0][:reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[1][0][:reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[2][0][:reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[3][0][:reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[0][0][reserve:2*reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[1][0][reserve:2*reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[2][0][reserve:2*reserve])/2**(reserve-2))
                    print("H: ", binary_abs(H_2d_array[3][0][reserve:2*reserve])/2**(reserve-2))
                    print("R11:", binary_abs(R_2d_array[0][0]) / 2**16)


                    #calculate normalized orthogonal vector
                    #Q format is S17.6
                    temp = round(binary_abs(H_2d_array[0][0][0:reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[0][0] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[0][0][reserve:2*reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[0][0] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][0][0:reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[1][0] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][0][reserve:2*reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[1][0] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][0][0:reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[2][0] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][0][reserve:2*reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[2][0] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][0][0:reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[3][0] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][0][reserve:2*reserve]) / int(R_2d_array[0][0],2))
                    Q_2d_array[3][0] += Q_format(int_to_bin(temp), reserve)

                    #calculate inner products
                    b_1 = binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][1][0:reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][1][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][1][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][1][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][1][0:reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][1][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][1][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][1][0:reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][1][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][1][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][1][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][1][0:reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][1][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][1][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][1][0:reserve])
                    R_2d_array[0][1] = Q_format(int_to_bin((b_2 + b_4 + b_6 + b_8))[:-10], 20)
                    R_2d_array[0][1] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)
                    b_1 = binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][2][0:reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][2][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][2][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][2][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][2][0:reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][2][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][2][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][2][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][2][0:reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][2][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][2][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][2][0:reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][2][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][2][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][2][0:reserve])
                    R_2d_array[0][2] = Q_format(int_to_bin(b_2 + b_4 + b_6 + b_8)[:-10], 20)
                    R_2d_array[0][2] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)
                    b_1 = binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][3][0:reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][3][0:reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][3][0:reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][3][0:reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][0:reserve])
                    R_2d_array[0][3] = Q_format(int_to_bin(b_2 + b_4 + b_6 + b_8)[:-10], 20)
                    R_2d_array[0][3] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)
                    
                    #calculate orthogonal vector h2 h3 h4
                    c_1 = binary_abs(H_2d_array[0][1][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][1][0:20]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][20:40])
                    c_2 = binary_abs(H_2d_array[0][1][0:reserve]) - binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][1][20:40]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][0:20])
                    H_2d_array[0][1] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][1][0:20]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][20:40])
                    c_2 = binary_abs(H_2d_array[1][1][0:reserve]) - binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][1][20:40]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][0:20])
                    H_2d_array[1][1] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][1][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][1][0:20]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][20:40])
                    c_2 = binary_abs(H_2d_array[2][1][0:reserve]) - binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][1][20:40]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][0:20])
                    H_2d_array[2][1] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][1][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][1][0:20]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][20:40])
                    c_2 = binary_abs(H_2d_array[3][1][0:reserve]) - binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][1][20:40]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][1][0:20])
                    H_2d_array[3][1] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    c_1 = binary_abs(H_2d_array[0][2][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][2][0:20]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][20:40])
                    c_2 = binary_abs(H_2d_array[0][2][0:reserve]) - binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][2][20:40]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][0:20])
                    H_2d_array[0][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][2][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][2][0:20]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][20:40])
                    c_2 = binary_abs(H_2d_array[1][2][0:reserve]) - binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][2][20:40]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][0:20])
                    H_2d_array[1][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][2][0:20]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][20:40])
                    c_2 = binary_abs(H_2d_array[2][2][0:reserve]) - binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][2][20:40]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][0:20])
                    H_2d_array[2][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][2][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][2][0:20]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][20:40])
                    c_2 = binary_abs(H_2d_array[3][2][0:reserve]) - binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][2][20:40]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][2][0:20])
                    H_2d_array[3][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    c_1 = binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][3][0:20]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][20:40])
                    c_2 = binary_abs(H_2d_array[0][3][0:reserve]) - binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(R_2d_array[0][3][20:40]) - binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][0:20])
                    H_2d_array[0][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][3][0:20]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][20:40])
                    c_2 = binary_abs(H_2d_array[1][3][0:reserve]) - binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(R_2d_array[0][3][20:40]) - binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][0:20])
                    H_2d_array[1][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][3][0:20]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][20:40])
                    c_2 = binary_abs(H_2d_array[2][3][0:reserve]) - binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(R_2d_array[0][3][20:40]) - binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][0:20])
                    H_2d_array[2][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][3][0:20]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][20:40])
                    c_2 = binary_abs(H_2d_array[3][3][0:reserve]) - binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(R_2d_array[0][3][20:40]) - binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(R_2d_array[0][3][0:20])
                    H_2d_array[3][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    #iteration 2
                    a_1 = binary_abs(H_2d_array[0][1][0:reserve]) ** 2
                    a_2 = binary_abs(H_2d_array[0][1][reserve:2*reserve]) ** 2
                    a_3 = binary_abs(H_2d_array[1][1][0:reserve]) ** 2
                    a_4 = binary_abs(H_2d_array[1][1][reserve:2*reserve]) ** 2
                    a_5 = binary_abs(H_2d_array[2][1][0:reserve]) ** 2
                    a_6 = binary_abs(H_2d_array[2][1][reserve:2*reserve]) ** 2
                    a_7 = binary_abs(H_2d_array[3][1][0:reserve]) ** 2
                    a_8 = binary_abs(H_2d_array[3][1][reserve:2*reserve]) ** 2
                    temp = a_1 + a_2 + a_3 + a_4 + a_5 + a_6 + a_7 + a_8
                    # R_2d_array[1][1] = R_format(sqrt_approximate(bin(temp)[2:].zfill(50)),0,20)
                    R_2d_array[1][1] = Q_format(int_to_bin(int(math.sqrt(temp) / 2**(reserve - 18))),20)
                    print("R22:", binary_abs(R_2d_array[1][1]) / 2**16)

                    #calculate normalized orthogonal vector
                    temp = round(binary_abs(H_2d_array[0][1][0:reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[0][1] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[0][1][reserve:2*reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[0][1] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][1][0:reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[1][1] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][1][reserve:2*reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[1][1] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][1][0:reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[2][1] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][1][reserve:2*reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[2][1] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][1][0:reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[3][1] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][1][reserve:2*reserve]) / int(R_2d_array[1][1],2))
                    Q_2d_array[3][1] += Q_format(int_to_bin(temp), reserve)

                    #calculate inner products
                    b_1 = binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(H_2d_array[0][2][0:reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(H_2d_array[0][2][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(H_2d_array[0][2][reserve:2*reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(H_2d_array[0][2][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(H_2d_array[1][2][0:reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(H_2d_array[1][2][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(H_2d_array[1][2][reserve:2*reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(H_2d_array[1][2][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(H_2d_array[2][2][0:reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(H_2d_array[2][2][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(H_2d_array[2][2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(H_2d_array[2][2][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(H_2d_array[3][2][0:reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(H_2d_array[3][2][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(H_2d_array[3][2][reserve:2*reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(H_2d_array[3][2][0:reserve])
                    R_2d_array[1][2] = Q_format(int_to_bin(b_2 + b_4 + b_6 + b_8)[:-10], 20)
                    R_2d_array[1][2] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)
                    b_1 = binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(H_2d_array[0][3][0:reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(H_2d_array[1][3][0:reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(H_2d_array[2][3][0:reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(H_2d_array[3][3][0:reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][0:reserve])
                    R_2d_array[1][3] = Q_format(int_to_bin(b_2 + b_4 + b_6 + b_8)[:-10], 20)
                    R_2d_array[1][3] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)
                    
                    #calculate orthogonal vector h3 h4
                    c_1 = binary_abs(H_2d_array[0][2][reserve:2*reserve]) + binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(R_2d_array[1][2][0:20]) - binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][20:40])
                    c_2 = binary_abs(H_2d_array[0][2][0:reserve]) - binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(R_2d_array[1][2][20:40]) - binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][0:20])
                    H_2d_array[0][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][2][reserve:2*reserve]) + binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(R_2d_array[1][2][0:20]) - binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][20:40])
                    c_2 = binary_abs(H_2d_array[1][2][0:reserve]) - binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(R_2d_array[1][2][20:40]) - binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][0:20])
                    H_2d_array[1][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(R_2d_array[1][2][0:20]) - binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][20:40])
                    c_2 = binary_abs(H_2d_array[2][2][0:reserve]) - binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(R_2d_array[1][2][20:40]) - binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][0:20])
                    H_2d_array[2][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][2][reserve:2*reserve]) + binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(R_2d_array[1][2][0:20]) - binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][20:40])
                    c_2 = binary_abs(H_2d_array[3][2][0:reserve]) - binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(R_2d_array[1][2][20:40]) - binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][2][0:20])
                    H_2d_array[3][2] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    c_1 = binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(R_2d_array[1][3][0:20]) - binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][20:40])
                    c_2 = binary_abs(H_2d_array[0][3][0:reserve]) - binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(R_2d_array[1][3][20:40]) - binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][0:20])
                    H_2d_array[0][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(R_2d_array[1][3][0:20]) - binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][20:40])
                    c_2 = binary_abs(H_2d_array[1][3][0:reserve]) - binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(R_2d_array[1][3][20:40]) - binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][0:20])
                    H_2d_array[1][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(R_2d_array[1][3][0:20]) - binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][20:40])
                    c_2 = binary_abs(H_2d_array[2][3][0:reserve]) - binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(R_2d_array[1][3][20:40]) - binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][0:20])
                    H_2d_array[2][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(R_2d_array[1][3][0:20]) - binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][20:40])
                    c_2 = binary_abs(H_2d_array[3][3][0:reserve]) - binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(R_2d_array[1][3][20:40]) - binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(R_2d_array[1][3][0:20])
                    H_2d_array[3][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    #iteration 3
                    a_1 = binary_abs(H_2d_array[0][2][0:reserve]) ** 2
                    a_2 = binary_abs(H_2d_array[0][2][reserve:2*reserve]) ** 2
                    a_3 = binary_abs(H_2d_array[1][2][0:reserve]) ** 2
                    a_4 = binary_abs(H_2d_array[1][2][reserve:2*reserve]) ** 2
                    a_5 = binary_abs(H_2d_array[2][2][0:reserve]) ** 2
                    a_6 = binary_abs(H_2d_array[2][2][reserve:2*reserve]) ** 2
                    a_7 = binary_abs(H_2d_array[3][2][0:reserve]) ** 2
                    a_8 = binary_abs(H_2d_array[3][2][reserve:2*reserve]) ** 2
                    temp = a_1 + a_2 + a_3 + a_4 + a_5 + a_6 + a_7 + a_8
                    # R_2d_array[2][2] = R_format(sqrt_approximate(bin(temp)[2:].zfill(50)),0,20)
                    R_2d_array[2][2] = Q_format(int_to_bin(int(math.sqrt(temp) / 2**(reserve - 18))),20)
                    print("R33:", binary_abs(R_2d_array[2][2]) / 2**16)

                    #calculate normalized orthogonal vector
                    temp = round(binary_abs(H_2d_array[0][2][0:reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[0][2] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[0][2][reserve:2*reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[0][2] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][2][0:reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[1][2] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][2][reserve:2*reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[1][2] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][2][0:reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[2][2] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][2][reserve:2*reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[2][2] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][2][0:reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[3][2] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][2][reserve:2*reserve]) / int(R_2d_array[2][2],2))
                    Q_2d_array[3][2] += Q_format(int_to_bin(temp), reserve)

                    #calculate inner products
                    b_1 = binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(H_2d_array[0][3][0:reserve]) + binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve])
                    b_2 = -binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(H_2d_array[0][3][0:reserve])
                    b_3 = binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(H_2d_array[1][3][0:reserve]) + binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve])
                    b_4 = -binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(H_2d_array[1][3][0:reserve])
                    b_5 = binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(H_2d_array[2][3][0:reserve]) + binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve])
                    b_6 = -binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(H_2d_array[2][3][0:reserve])
                    b_7 = binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(H_2d_array[3][3][0:reserve]) + binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve])
                    b_8 = -binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(H_2d_array[3][3][0:reserve])
                    R_2d_array[2][3] = Q_format(int_to_bin(b_2 + b_4 + b_6 + b_8)[:-10], 20)
                    R_2d_array[2][3] += Q_format(int_to_bin(b_1 + b_3 + b_5 + b_7)[:-10], 20)

                    #calculate orthogonal vector h4
                    c_1 = binary_abs(H_2d_array[0][3][reserve:2*reserve]) + binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(R_2d_array[2][3][0:20]) - binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][20:40])
                    c_2 = binary_abs(H_2d_array[0][3][0:reserve]) - binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(R_2d_array[2][3][20:40]) - binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][0:20])
                    H_2d_array[0][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[1][3][reserve:2*reserve]) + binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(R_2d_array[2][3][0:20]) - binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][20:40])
                    c_2 = binary_abs(H_2d_array[1][3][0:reserve]) - binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(R_2d_array[2][3][20:40]) - binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][0:20])
                    H_2d_array[1][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[2][3][reserve:2*reserve]) + binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(R_2d_array[2][3][0:20]) - binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][20:40])
                    c_2 = binary_abs(H_2d_array[2][3][0:reserve]) - binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(R_2d_array[2][3][20:40]) - binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][0:20])
                    H_2d_array[2][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)
                    c_1 = binary_abs(H_2d_array[3][3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(R_2d_array[2][3][0:20]) - binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][20:40])
                    c_2 = binary_abs(H_2d_array[3][3][0:reserve]) - binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(R_2d_array[2][3][20:40]) - binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(R_2d_array[2][3][0:20])
                    H_2d_array[3][3] = Q_format(int_to_bin(c_2), reserve) + Q_format(int_to_bin(c_1), reserve)

                    #iteration 4
                    a_1 = binary_abs(H_2d_array[0][3][0:reserve]) ** 2
                    a_2 = binary_abs(H_2d_array[0][3][reserve:2*reserve]) ** 2
                    a_3 = binary_abs(H_2d_array[1][3][0:reserve]) ** 2
                    a_4 = binary_abs(H_2d_array[1][3][reserve:2*reserve]) ** 2
                    a_5 = binary_abs(H_2d_array[2][3][0:reserve]) ** 2
                    a_6 = binary_abs(H_2d_array[2][3][reserve:2*reserve]) ** 2
                    a_7 = binary_abs(H_2d_array[3][3][0:reserve]) ** 2
                    a_8 = binary_abs(H_2d_array[3][3][reserve:2*reserve]) ** 2
                    temp = a_1 + a_2 + a_3 + a_4 + a_5 + a_6 + a_7 + a_8
                    # R_2d_array[3][3] = R_format(sqrt_approximate(bin(temp)[2:].zfill(50)),0,20)
                    R_2d_array[3][3] = Q_format(int_to_bin(int(math.sqrt(temp) / 2**(reserve - 18))),20)
                    print("R44:", binary_abs(R_2d_array[3][3]) / 2**16)

                    #calculate normalized orthogonal vector
                    temp = round(binary_abs(H_2d_array[0][3][0:reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[0][3] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[0][3][reserve:2*reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[0][3] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][3][0:reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[1][3] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[1][3][reserve:2*reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[1][3] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][3][0:reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[2][3] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[2][3][reserve:2*reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[2][3] += Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][3][0:reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[3][3] = Q_format(int_to_bin(temp), reserve)
                    temp = round(binary_abs(H_2d_array[3][3][reserve:2*reserve]) / int(R_2d_array[3][3],2))
                    Q_2d_array[3][3] += Q_format(int_to_bin(temp), reserve)

                    #calculate y_hat
                    d_1 = binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(y_array[0][0:reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(y_array[0][reserve:2*reserve])
                    d_2 = -binary_abs(Q_2d_array[0][0][0:reserve]) * binary_abs(y_array[0][reserve:2*reserve]) + binary_abs(Q_2d_array[0][0][reserve:2*reserve]) * binary_abs(y_array[0][0:reserve])
                    d_3 = binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(y_array[1][0:reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(y_array[1][reserve:2*reserve])
                    d_4 = -binary_abs(Q_2d_array[1][0][0:reserve]) * binary_abs(y_array[1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][0][reserve:2*reserve]) * binary_abs(y_array[1][0:reserve])
                    d_5 = binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(y_array[2][0:reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(y_array[2][reserve:2*reserve])
                    d_6 = -binary_abs(Q_2d_array[2][0][0:reserve]) * binary_abs(y_array[2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][0][reserve:2*reserve]) * binary_abs(y_array[2][0:reserve])
                    d_7 = binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(y_array[3][0:reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(y_array[3][reserve:2*reserve])
                    d_8 = -binary_abs(Q_2d_array[3][0][0:reserve]) * binary_abs(y_array[3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][0][reserve:2*reserve]) * binary_abs(y_array[3][0:reserve])
                    y_hat_array[0] = Q_format(int_to_bin(d_2 + d_4 + d_6 + d_8)[:-10], 20)
                    y_hat_array[0] += Q_format(int_to_bin(d_1 + d_3 + d_5 + d_7)[:-10], 20)

                    d_1 = binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(y_array[0][0:reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(y_array[0][reserve:2*reserve])
                    d_2 = -binary_abs(Q_2d_array[0][1][0:reserve]) * binary_abs(y_array[0][reserve:2*reserve]) + binary_abs(Q_2d_array[0][1][reserve:2*reserve]) * binary_abs(y_array[0][0:reserve])
                    d_3 = binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(y_array[1][0:reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(y_array[1][reserve:2*reserve])
                    d_4 = -binary_abs(Q_2d_array[1][1][0:reserve]) * binary_abs(y_array[1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][1][reserve:2*reserve]) * binary_abs(y_array[1][0:reserve])
                    d_5 = binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(y_array[2][0:reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(y_array[2][reserve:2*reserve])
                    d_6 = -binary_abs(Q_2d_array[2][1][0:reserve]) * binary_abs(y_array[2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][1][reserve:2*reserve]) * binary_abs(y_array[2][0:reserve])
                    d_7 = binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(y_array[3][0:reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(y_array[3][reserve:2*reserve])
                    d_8 = -binary_abs(Q_2d_array[3][1][0:reserve]) * binary_abs(y_array[3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][1][reserve:2*reserve]) * binary_abs(y_array[3][0:reserve])
                    y_hat_array[1] = Q_format(int_to_bin(d_2 + d_4 + d_6 + d_8)[:-10], 20)
                    y_hat_array[1] += Q_format(int_to_bin(d_1 + d_3 + d_5 + d_7)[:-10], 20)

                    d_1 = binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(y_array[0][0:reserve]) + binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(y_array[0][reserve:2*reserve])
                    d_2 = -binary_abs(Q_2d_array[0][2][0:reserve]) * binary_abs(y_array[0][reserve:2*reserve]) + binary_abs(Q_2d_array[0][2][reserve:2*reserve]) * binary_abs(y_array[0][0:reserve])
                    d_3 = binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(y_array[1][0:reserve]) + binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(y_array[1][reserve:2*reserve])
                    d_4 = -binary_abs(Q_2d_array[1][2][0:reserve]) * binary_abs(y_array[1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][2][reserve:2*reserve]) * binary_abs(y_array[1][0:reserve])
                    d_5 = binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(y_array[2][0:reserve]) + binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(y_array[2][reserve:2*reserve])
                    d_6 = -binary_abs(Q_2d_array[2][2][0:reserve]) * binary_abs(y_array[2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][2][reserve:2*reserve]) * binary_abs(y_array[2][0:reserve])
                    d_7 = binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(y_array[3][0:reserve]) + binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(y_array[3][reserve:2*reserve])
                    d_8 = -binary_abs(Q_2d_array[3][2][0:reserve]) * binary_abs(y_array[3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][2][reserve:2*reserve]) * binary_abs(y_array[3][0:reserve])
                    y_hat_array[2] = Q_format(int_to_bin(d_2 + d_4 + d_6 + d_8)[:-10], 20)
                    y_hat_array[2] += Q_format(int_to_bin(d_1 + d_3 + d_5 + d_7)[:-10], 20)
                    
                    d_1 = binary_abs(Q_2d_array[0][3][0:reserve]) * binary_abs(y_array[0][0:reserve]) + binary_abs(Q_2d_array[0][3][reserve:2*reserve]) * binary_abs(y_array[0][reserve:2*reserve])
                    d_2 = -binary_abs(Q_2d_array[0][3][0:reserve]) * binary_abs(y_array[0][reserve:2*reserve]) + binary_abs(Q_2d_array[0][3][reserve:2*reserve]) * binary_abs(y_array[0][0:reserve])
                    d_3 = binary_abs(Q_2d_array[1][3][0:reserve]) * binary_abs(y_array[1][0:reserve]) + binary_abs(Q_2d_array[1][3][reserve:2*reserve]) * binary_abs(y_array[1][reserve:2*reserve])
                    d_4 = -binary_abs(Q_2d_array[1][3][0:reserve]) * binary_abs(y_array[1][reserve:2*reserve]) + binary_abs(Q_2d_array[1][3][reserve:2*reserve]) * binary_abs(y_array[1][0:reserve])
                    d_5 = binary_abs(Q_2d_array[2][3][0:reserve]) * binary_abs(y_array[2][0:reserve]) + binary_abs(Q_2d_array[2][3][reserve:2*reserve]) * binary_abs(y_array[2][reserve:2*reserve])
                    d_6 = -binary_abs(Q_2d_array[2][3][0:reserve]) * binary_abs(y_array[2][reserve:2*reserve]) + binary_abs(Q_2d_array[2][3][reserve:2*reserve]) * binary_abs(y_array[2][0:reserve])
                    d_7 = binary_abs(Q_2d_array[3][3][0:reserve]) * binary_abs(y_array[3][0:reserve]) + binary_abs(Q_2d_array[3][3][reserve:2*reserve]) * binary_abs(y_array[3][reserve:2*reserve])
                    d_8 = -binary_abs(Q_2d_array[3][3][0:reserve]) * binary_abs(y_array[3][reserve:2*reserve]) + binary_abs(Q_2d_array[3][3][reserve:2*reserve]) * binary_abs(y_array[3][0:reserve])
                    y_hat_array[3] = Q_format(int_to_bin(d_2 + d_4 + d_6 + d_8)[:-10], 20)
                    y_hat_array[3] += Q_format(int_to_bin(d_1 + d_3 + d_5 + d_7)[:-10], 20)
                    hex_string = ''.join(hex(int(R_2d_array[3][3][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[3][3]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[2][3][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[2][3]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[1][3][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[1][3]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[0][3][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[0][3]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[2][2][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[2][2]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[1][2][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[1][2]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[0][2][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[0][2]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[1][1][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[1][1]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[0][1][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[0][1]), 4))
                    hex_string += ''.join(hex(int(R_2d_array[0][0][i:i+4], 2))[2:] for i in range(0, len(R_2d_array[0][0]), 4))
                    file_1.write(hex_string + "\n")
                    hex_string = ''.join(hex(int(y_hat_array[3][i:i+4], 2))[2:] for i in range(0, len(y_hat_array[3]), 4))
                    hex_string += ''.join(hex(int(y_hat_array[2][i:i+4], 2))[2:] for i in range(0, len(y_hat_array[2]), 4))
                    hex_string += ''.join(hex(int(y_hat_array[1][i:i+4], 2))[2:] for i in range(0, len(y_hat_array[1]), 4))
                    hex_string += ''.join(hex(int(y_hat_array[0][i:i+4], 2))[2:] for i in range(0, len(y_hat_array[0]), 4))
                    file_2.write(hex_string + "\n")
                    # break
                    

# # Binary string to convert to hexadecimal
# binary_string = '101010'

# # Convert binary string to hexadecimal string
# hex_string = hex(int(binary_string, 2))[2:]

# print(hex_string)


# Hexadecimal string

hex_string_1 = "09be1"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R44:",binary_abs(binary) / 2**16)
binary = R_2d_array[3][3]
print("re_R44:",binary_abs(binary) / 2**16)

hex_string_1 = "fb09a"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R34:",binary_abs(binary) / 2**16)
binary = R_2d_array[2][3][0:20]
print("im_R34:",binary_abs(binary) / 2**16)

hex_string_1 = "fc548"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R34:",binary_abs(binary) / 2**16)
binary = R_2d_array[2][3][20:40]
print("re_R34:",binary_abs(binary) / 2**16)

hex_string_1 = "ef308"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R24:",binary_abs(binary) / 2**16)
binary = R_2d_array[1][3][0:20]
print("im_R24:",binary_abs(binary) / 2**16)

hex_string_1 = "fb344"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R24:",binary_abs(binary) / 2**16)
binary = R_2d_array[1][3][20:40]
print("re_R24:",binary_abs(binary) / 2**16)

hex_string_1 = "08855"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R14:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][3][0:20]
print("im_R14:",binary_abs(binary) / 2**16)

hex_string_1 = "ff075"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R14:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][3][20:40]
print("re_R14:",binary_abs(binary) / 2**16)

hex_string_1 = "0586b"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R33:",binary_abs(binary) / 2**16)
binary = R_2d_array[2][2]
print("re_R33:",binary_abs(binary) / 2**16)

hex_string_1 = "03f04"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R23:",binary_abs(binary) / 2**16)
binary = R_2d_array[1][2][0:20]
print("im_R23:",binary_abs(binary) / 2**16)

hex_string_1 = "01087"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R23:",binary_abs(binary) / 2**16)
binary = R_2d_array[1][2][20:40]
print("re_R23:",binary_abs(binary) / 2**16)

hex_string_1 = "0080b"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R13:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][2][0:20]
print("im_R13:",binary_abs(binary) / 2**16)

hex_string_1 = "056ee"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R13:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][2][20:40]
print("re_R13:",binary_abs(binary) / 2**16)

hex_string_1 = "0c96c"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R22:",binary_abs(binary) / 2**16)
binary = R_2d_array[1][1]
print("re_R22:",binary_abs(binary) / 2**16)

hex_string_1 = "fb7d2"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_R12:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][1][0:20]
print("im_R12:",binary_abs(binary) / 2**16)

hex_string_1 = "faf1f"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R12:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][1][20:40]
print("re_R12:",binary_abs(binary) / 2**16)

hex_string_1 = "0e977"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_R11:",binary_abs(binary) / 2**16)
binary = R_2d_array[0][0]
print("re_R11:",binary_abs(binary) / 2**16)

hex_string_1 = "f3acd"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_y1:",binary_abs(binary) / 2**16)
binary = y_hat_array[0][0:20]
print("im_y1:",binary_abs(binary) / 2**16)

hex_string_1 = "fc309"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_y1:",binary_abs(binary) / 2**16)
binary = y_hat_array[0][20:40]
print("re_y1:",binary_abs(binary) / 2**16)


hex_string_1 = "16051"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_y2:",binary_abs(binary) / 2**16)
binary = y_hat_array[1][0:20]
print("re_y2:",binary_abs(binary) / 2**16)

hex_string_1 = "08fa6"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_y2:",binary_abs(binary) / 2**16)
binary = y_hat_array[1][20:40]
print("re_y2:",binary_abs(binary) / 2**16)


hex_string_1 = "04057"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_y3:",binary_abs(binary) / 2**16)
binary = y_hat_array[2][0:20]
print("im_y3:",binary_abs(binary) / 2**16)

hex_string_1 = "116e5"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_y3:",binary_abs(binary) / 2**16)
binary = y_hat_array[2][20:40]
print("re_y3:",binary_abs(binary) / 2**16)

hex_string_1 = "08324"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("im_y4:",binary_abs(binary) / 2**16)
binary = y_hat_array[3][0:20]
print("im_y4:",binary_abs(binary) / 2**16)

hex_string_1 = "f697a"
binary = bin(int(hex_string_1, 16))[2:].zfill(20)
print("re_y4:",binary_abs(binary) / 2**16)
binary = y_hat_array[3][20:40]
print("re_y4:",binary_abs(binary) / 2**16)

