#!/usr/bin/env python3
"""
A direct test using echo and a shell pipeline (known to work).
"""
import subprocess
import tempfile
import os

def run_test():
    """Test the pydantic-run-python MCP with a simple shell pipeline."""
    # Create a temporary file to hold the JSON payload
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("""{
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "run_python_code",
                "arguments": {
                    "python_code": "print('Hello, MCP!')\nresult = 2 + 2\nprint(f'Result: {result}')\nresult"
                }
            },
            "id": 1
        }""")
        payload_file = f.name
    
    # Use a shell command that we know works
    cmd = f"cat {payload_file} | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio"
    
    try:
        print(f"Running command: {cmd}")
        output = subprocess.check_output(cmd, shell=True, text=True)
        print("Output:")
        print(output)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
    finally:
        # Clean up temporary file
        os.unlink(payload_file)

# Run multiple algorithms
def test_algorithms():
    """Test all our algorithms."""
    # Test factorial
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("""{
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "run_python_code",
                "arguments": {
                    "python_code": "def factorial(n):\\n    result = 1\\n    for i in range(2, n + 1):\\n        result *= i\\n    return result\\n\\nresult = factorial(5)\\nprint(f'Factorial of 5 = {result}')\\nresult"
                }
            },
            "id": 1
        }""")
        factorial_file = f.name
    
    # Test Fibonacci
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("""{
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "run_python_code",
                "arguments": {
                    "python_code": "def fibonacci(n):\\n    if n <= 1:\\n        return n\\n    a, b = 0, 1\\n    for _ in range(2, n + 1):\\n        a, b = b, a + b\\n    return b\\n\\nresult = fibonacci(10)\\nprint(f'Fibonacci of 10 = {result}')\\nresult"
                }
            },
            "id": 1
        }""")
        fibonacci_file = f.name
    
    # Test Prime
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("""{
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "run_python_code",
                "arguments": {
                    "python_code": "def is_prime(n):\\n    if n <= 1:\\n        return False\\n    if n <= 3:\\n        return True\\n    if n % 2 == 0 or n % 3 == 0:\\n        return False\\n    i = 5\\n    while i * i <= n:\\n        if n % i == 0 or n % (i + 2) == 0:\\n            return False\\n        i += 6\\n    return True\\n\\nresult = is_prime(17)\\nprint(f'Is 17 prime? {result}')\\nresult"
                }
            },
            "id": 1
        }""")
        prime_file = f.name
    
    try:
        # Run factorial
        print("=== Testing Factorial Algorithm ===")
        cmd = f"cat {factorial_file} | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio"
        output = subprocess.check_output(cmd, shell=True, text=True)
        print(output)
        
        # Run Fibonacci
        print("\n=== Testing Fibonacci Algorithm ===")
        cmd = f"cat {fibonacci_file} | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio"
        output = subprocess.check_output(cmd, shell=True, text=True)
        print(output)
        
        # Run Prime
        print("\n=== Testing Prime Algorithm ===")
        cmd = f"cat {prime_file} | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio"
        output = subprocess.check_output(cmd, shell=True, text=True)
        print(output)
        
    finally:
        # Clean up temporary files
        os.unlink(factorial_file)
        os.unlink(fibonacci_file)
        os.unlink(prime_file)

if __name__ == "__main__":
    # Run the basic test
    run_test()
    
    # Run all algorithm tests
    test_algorithms()