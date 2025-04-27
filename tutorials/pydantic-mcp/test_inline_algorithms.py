#!/usr/bin/env python3
"""
Test script to run our algorithms directly in the MCP sandbox.
"""
import subprocess
import json
import os

def run_mcp_python(code):
    """Run Python code with MCP and return the result."""
    payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "run_python_code",
            "arguments": {
                "python_code": code
            }
        },
        "id": 1
    }
    
    cmd = ['deno', 'run', '-N', '-R=node_modules', '-W=node_modules', 
           '--node-modules-dir=auto', '--allow-read=.', 
           'jsr:@pydantic/mcp-run-python', 'stdio']
    
    process = subprocess.run(
        cmd,
        input=json.dumps(payload).encode(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    if process.returncode != 0:
        print(f"Error: {process.stderr.decode()}")
        return None
    
    try:
        response = json.loads(process.stdout.decode())
        if "result" in response:
            print(response["result"]["content"][0]["text"])
            return response["result"]["content"][0]["text"]
        else:
            print(f"Error in response: {response}")
            return None
    except json.JSONDecodeError:
        print(f"Invalid JSON response: {process.stdout.decode()}")
        return None

if __name__ == "__main__":
    # Change to the project root directory
    os.chdir("/home/aygp-dr/projects/aygp-dr/isolated-pymcp")
    
    print("=== Testing Factorial Algorithm ===")
    factorial_code = """
# Direct implementation of factorial_iterative
def factorial_iterative(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result

# Call the function
result = factorial_iterative(5)
print(f"Factorial of 5 = {result}")
result
"""
    run_mcp_python(factorial_code)
    
    print("\n=== Testing Fibonacci Algorithm ===")
    fibonacci_code = """
# Direct implementation of fib_iterative
def fib_iterative(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

# Call the function
result = fib_iterative(10)
print(f"Fibonacci of 10 = {result}")
result
"""
    run_mcp_python(fibonacci_code)
    
    print("\n=== Testing Prime Algorithm ===")
    prime_code = """
# Direct implementation of is_prime_optimized
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

# Call the function
result = is_prime_optimized(17)
print(f"Is 17 prime? {result}")
result
"""
    run_mcp_python(prime_code)