BASE = 16953

for i in range(0, 12):
    freq = round((BASE * 2**(i/12)) / 7.8125)
    print(f'${freq:X}, ', end=" ")