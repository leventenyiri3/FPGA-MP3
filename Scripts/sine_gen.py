import math

WIDTH = 16
DEPTH = 1024

# For Signed 16-bit, max value is 32767 (2^15 - 1)
MAX_AMPLITUDE = 2**(WIDTH - 1) - 1 

BIT_MASK = 2**WIDTH - 1

print(f"Generating {DEPTH} samples, {WIDTH}-bit Signed...")

with open("sine_lut.mem", "w") as f:
    for index in range(DEPTH):
        
        theta = (2 * math.pi * index) / DEPTH
        
        raw_float = math.sin(theta)
        
        int_val = round(raw_float * MAX_AMPLITUDE)
        
        masked_val = int_val & BIT_MASK
        
        # Write to file (Format as 4-digit Hex)
        # f"{val:04x}" handles the hex conversion and padding automatically
        f.write(f"{masked_val:04x}\n")

print("Done! File 'sine_lut.mem' created.")
