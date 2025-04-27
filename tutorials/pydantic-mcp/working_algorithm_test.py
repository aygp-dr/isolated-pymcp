#!/usr/bin/env python3
"""
A working test for running our algorithms with the pydantic-run-python MCP.
"""
import subprocess
import json
import tempfile
import os

def run_algorithm_code(algorithm_code, description):
    """Run the algorithm code through the MCP server."""
    payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "run_python_code",
            "arguments": {
                "python_code": algorithm_code
            }
        },
        "id": 1
    }
    
    # Save payload to a temporary file
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        json.dump(payload, f)
        temp_file = f.name
    
    # Run the command
    print(f"=== Testing {description} ===")
    cmd = f"cat {temp_file} | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio"
    
    try:
        output = subprocess.check_output(cmd, shell=True, text=True)
        print("Output:")
        print(output)
        
        # Parse the response
        response = json.loads(output)
        if "result" in response:
            result_text = response["result"]["content"][0]["text"]
            print(f"Result text: {result_text}")
        else:
            print(f"Unexpected response structure: {response}")
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        print(f"Raw output: {output}")
    finally:
        # Clean up the temporary file
        os.unlink(temp_file)

if __name__ == "__main__":
    # Test factorial
    factorial_code = """
def factorial_iterative(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result

result = factorial_iterative(5)
print(f"Factorial of 5 = {result}")
result
"""
    run_algorithm_code(factorial_code, "Factorial Algorithm")
    
    # Test Fibonacci
    fibonacci_code = """
def fib_iterative(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

result = fib_iterative(10)
print(f"Fibonacci of 10 = {result}")
result
"""
    run_algorithm_code(fibonacci_code, "Fibonacci Algorithm")
    
    # Test Prime
    prime_code = """
def is_prime_optimized(n):
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    
    return True

result = is_prime_optimized(17)
print(f"Is 17 prime? {result}")
result
"""
    run_algorithm_code(prime_code, "Prime Number Algorithm")