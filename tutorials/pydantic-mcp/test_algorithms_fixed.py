#!/usr/bin/env python3
"""
Test script to run our algorithms with pydantic-run-python MCP.
"""
import subprocess
import json
import sys
import os

def run_algorithm(algorithm_name, function_name, *args):
    """
    Run a local algorithm through MCP.
    
    Args:
        algorithm_name: Name of the algorithm module (without .py)
        function_name: Name of the function to call
        *args: Arguments to pass to the function
    """
    # Construct the Python code to run
    args_str = ", ".join(repr(arg) for arg in args)
    
    code = f"""
import sys
sys.path.append('.')
from algorithms.{algorithm_name} import {function_name}

# Run the algorithm
result = {function_name}({args_str})
print(f"Result of {function_name}({args_str}) = {{result}}")

# Return the result
result
"""
    
    # Create a direct shell command that we know works
    cmd = f'''echo '{{"jsonrpc": "2.0", "method": "tools/call", "params": {{"name": "run_python_code", "arguments": {{"python_code": {json.dumps(code)}}} }}, "id": 1}}' | deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. jsr:@pydantic/mcp-run-python stdio'''
    
    print(f"Running command: {cmd}")
    
    # Execute the command
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Error executing command: {result.stderr}")
        return None
    
    if not result.stdout:
        print("No output received")
        return None
    
    try:
        response = json.loads(result.stdout)
        if "result" in response:
            print(response["result"]["content"][0]["text"])
            return response["result"]["content"][0]["text"]
        elif "error" in response:
            print(f"Error: {response['error']}")
            return None
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        print(f"Raw output: {result.stdout}")
        return None
    
    return None

if __name__ == "__main__":
    # Make sure we're in the project root directory
    os.chdir("/home/aygp-dr/projects/aygp-dr/isolated-pymcp")
    
    # Example: Run each of our algorithms
    print("=== Testing Factorial Algorithm ===")
    run_algorithm("factorial", "factorial_iterative", 5)
    
    print("\n=== Testing Fibonacci Algorithm ===")
    run_algorithm("fibonacci", "fib_iterative", 10)
    
    print("\n=== Testing Prime Number Algorithm ===")
    run_algorithm("primes", "is_prime_optimized", 17)