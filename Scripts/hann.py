import math

WIDTH = 16
DEPTH = 1024

# For Signed 16-bit, max value is 32767 (2^15 - 1)
MAX_AMPLITUDE = 2**(WIDTH - 1) - 1 

BIT_MASK = 2**WIDTH - 1

print(f"Generating Hann window for N={DEPTH} point FFT")

with open(f"hann_{DEPTH}_coeffs.mem", "w") as f:
    for index in range(DEPTH):

        Hann_raw = 0.5 * (1-math.cos((2*math.pi*index)/(DEPTH)))

        Hann_integer = round(Hann_raw * MAX_AMPLITUDE)

        Hann_masked = Hann_integer & BIT_MASK
        
        f.write(f"{Hann_masked:04x}\n")

print(f"File hann_{DEPTH}_coeffs.mem created")





