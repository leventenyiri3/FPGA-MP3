def to_signed(val, bits):
    """Converts a positive integer to a signed two's complement integer."""
    if val & (1 << (bits - 1)):
        val = val - (1 << bits)
    return val

# 1. Get user input
hex_str1 = input("Enter first hex number: ")
hex_str2 = input("Enter second hex number: ")

# 2. Convert hex strings to integers
# Python handles the '0x' prefix automatically if present
val1_raw = int(hex_str1, 16)
val2_raw = int(hex_str2, 16)

# 3. Apply signed logic (adjust bits based on your Verilog widths)
# In your Verilog: sample_to_mul is 16-bit, coeff is 32-bit
val1 = to_signed(val1_raw, 16)
val2 = to_signed(val2_raw, 32)

# 4. Perform multiplication
mul_res = val1 * val2

# 5. Display results
print(f"\n--- Signed Interpretation ---")
print(f"Value 1: {val1}")
print(f"Value 2: {val2}")
print(f"Product (Decimal): {mul_res}")

# 6. Show what it looks like in a 59-bit Verilog wire (masking)
# This matches the '7fffffffe1da800' you saw in the waveform
verilog_hex = hex(mul_res & (2**59 - 1))
print(f"Product (Hex, 59-bit mask): {verilog_hex}")


