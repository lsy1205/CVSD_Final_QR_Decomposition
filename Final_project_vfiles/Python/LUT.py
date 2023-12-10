for i in range(64):
    print(bin(round(1/(64+i)*(2**21)))[2:].zfill(16))
