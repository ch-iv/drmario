import re
import sys

def binary_to_hex(match):
    """Convert a binary string (0b...) to hexadecimal (0x...)."""
    # Extract the binary digits after '0b'
    binary_str = match.group(1)
    # Convert binary to integer, then to hex
    decimal_value = int(binary_str, 2)
    # Return hexadecimal representation
    return f"0x{decimal_value:X}"

def convert_file(input_file, output_file=None):
    """Read source code and convert all binary numbers to hexadecimal."""
    try:
        # Read the input file
        with open(input_file, 'r') as f:
            content = f.read()
        
        # Use regex to find and replace all binary numbers
        # Pattern looks for '0b' followed by one or more 0's and 1's
        pattern = r'0b([01]+)'
        converted_content = re.sub(pattern, lambda m: binary_to_hex(m), content)
        
        # Write the converted content
        if output_file:
            with open(output_file, 'w') as f:
                f.write(converted_content)
            print(f"Converted content written to {output_file}")
        else:
            # If no output file is specified, modify the original file
            with open(input_file, 'w') as f:
                f.write(converted_content)
            print(f"Original file {input_file} has been updated")
            
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python binary_to_hex.py input_file [output_file]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    convert_file(input_file, output_file)
