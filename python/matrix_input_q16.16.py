import os
import math

MEM_PATH = "C:/Users/Devangi Chaudhary/Desktop/internships/BEL PDIC/Vivado/QRD_datapath/Amatrix.mem"

FRAC_BITS  = 16
TOTAL_BITS = 32
INT_BITS   = TOTAL_BITS - FRAC_BITS  # 16 bits → range ±32767

def float_to_q16_16(val):
    scaled = int(round(val * (2 ** FRAC_BITS)))
    if scaled < 0:
        scaled = scaled + (1 << TOTAL_BITS)
    scaled = scaled & 0xFFFFFFFF
    return scaled

def main():
    n = int(input("Size of square matrix N: "))

    Q16_16_LIMIT = (2 ** (INT_BITS - 1)) - 1 / (2 ** FRAC_BITS)
    SAFE_LIMIT   = (2 ** (INT_BITS - 1)) / math.sqrt(n)

    print(f"\nQ16.16 storage limit:    +/- {Q16_16_LIMIT:.4f}")
    print(f"Safe computation limit:  +/- {SAFE_LIMIT:.4f}")

    A = []
    print(f"\nEnter elements of {n}x{n} matrix:")
    for i in range(n):
        row = []
        for j in range(n):
            while True:
                try:
                    val = float(input(f"  A[{i}][{j}] = "))

                    if val >= 32768 or val < -32768:
                        print(f"  Error: {val} exceeds Q16.16 storage limit of +/-32768. Try again.")
                        continue

                    if abs(val) > SAFE_LIMIT:
                        print(f"  Warning: {val} exceeds safe computation limit of +/-{SAFE_LIMIT:.4f}")
                        print(f"  Dot product overflow may occur for N={n}")
                        confirm = input("  Continue anyway? (y/n): ")
                        if confirm.lower() != 'y':
                            continue

                    row.append(val)
                    break

                except ValueError:
                    print(f"  Error: invalid input. Enter a number.")
        A.append(row)

    print("\nMatrix entered:")
    for i in range(n):
        print(" ", A[i])

    with open(MEM_PATH, "w") as f:
        for col in range(n):
            line = ""
            for row in range(n-1, -1, -1):
                hex_val = float_to_q16_16(A[row][col])
                line += f"{hex_val:08X}"
            f.write(line + "\n")

    print(f"\nMemory file written to: {MEM_PATH}")

    print("\nAmatrix.mem contents:")
    with open(MEM_PATH, "r") as f:
        lines = f.readlines()
        for col, line in enumerate(lines):
            print(f"  col {col}: {line.strip()}")

    print("\nVerification (decoded back to float):")
    for col in range(n):
        line = lines[col].strip()
        print(f"  Column {col}:")
        for row in range(n):
            hex_str = line[(n-1-row)*8 : (n-row)*8]
            int_val = int(hex_str, 16)
            if int_val >= (1 << 31):
                int_val -= (1 << 32)
            float_val = int_val / (2 ** FRAC_BITS)
            print(f"    A[{row}][{col}] = {float_val} (hex: {hex_str})")

if __name__ == "__main__":
    main()
