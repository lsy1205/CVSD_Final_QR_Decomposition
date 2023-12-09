from random import randint

error = 0
# for i in range(10000):
offset = 8
a = randint(2**10, 2**15)
b = randint(a, min(2**16, a*10))
print(a/b)
a <<= 8
b <<= 8
print(a)
print(b)
if (b >> (15 + offset) & 1):
    b >>= 2
    a >>= 2
elif (b >> (14 + offset) & 1):
    b >>= 1
    a >>= 1
elif (b >> (13 + offset) & 1):
    b >>= 0
    a >>= 0
elif (b >> (12 + offset) & 1):
    b <<= 1
    a <<= 1
elif (b >> (11 + offset) & 1):
    b <<= 2
    a <<= 2
elif (b >> (10 + offset) & 1):
    b <<= 3
    a <<= 3
elif (b >> (9 + offset) & 1):
    b <<= 4
    a <<= 4
elif (b >> (8 + offset) & 1):
    b <<= 5
    a <<= 5
elif (b >> (7 + offset) & 1):
    b <<= 6
    a <<= 6
elif (b >> (6 + offset) & 1):
    b <<= 7
    a <<= 7
elif (b >> (5 + offset) & 1):
    b <<= 8
    a <<= 8
elif (b >> (4 + offset) & 1):
    b <<= 9
    a <<= 9
elif (b >> (3 + offset) & 1):
    b <<= 10
    a <<= 10
elif (b >> (2 + offset) & 1):
    b <<= 11
    a <<= 11
elif (b >> (1 + offset) & 1):
    b <<= 12
    a <<= 12

temp = b * 1
temp2 = a * 1
print(temp)
print(a)
count = 0
cnt = 0
if (temp >> (12 + offset) & 1 == 0):
    b += temp >> 1
    a += temp2 >> 1
    count += 1
else:
    cnt += 1
if (temp >> (11 + offset) & 1 == 0):
    b += temp >> 2
    a += temp2 >> 2
    count += 1
else:
    cnt += 1
if (temp >> (10 + offset) & 1 == 0):
    b += temp >> 3
    a += temp2 >> 3
    count += 1
else:
    cnt += 1
if (temp >> (9 + offset) & 1 == 0):
    b += temp >> 4
    a += temp2 >> 4
    count += 1
else:
    cnt += 1
if (count == 4):
    b += temp >> 4
    a += temp2 >> 4
if (cnt == 4):
    b += temp >> 5
    a += temp2 >> 5
temp = b * 1
temp2 = a * 1
print(b)
print(a)
# print("temp = ", bin(temp))
if (((temp >> (10 + offset) & 1) == 0) & ((temp >> (9 + offset) & 1) == 0) & ((temp >> (8 + offset) & 1) == 0) & ((temp >> (7 + offset) & 1) == 1)):
    b -= temp >> 8
    a -= temp2 >> 8
else:
    cnt = 0
    if (temp >> (10 + offset) & 1 == 1):
        b -= temp >> 4
        a -= temp2 >> 4
        cnt += 1
    if (temp >> (9 + offset) & 1 == 1):
        b -= temp >> 5
        a -= temp2 >> 5
        cnt += 1
    if (temp >> (8 + offset) & 1 == 1):
        b -= temp >> 6
        a -= temp2 >> 6
        cnt += 1
    if (temp >> (7 + offset) & 1 == 1):
        b -= temp >> 7
        a -= temp2 >> 7
        cnt += 1
    if (cnt > 0):
        b += temp >> 8
        a += temp2 >> 8
print(b)
print(a)
print(b/2**22 -1)
    # error += abs(b / 2**22 - 1)
# print(error / 10000)