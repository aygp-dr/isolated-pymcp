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
    
    # Run the code through MCP
    deno_args = [
        "deno",
        "run",
        "-N",
        "-R=node_modules",
        "-W=node_modules",
        "--node-modules-dir=auto",
        "--allow-read",
        "jsr:@pydantic/mcp-run-python",
        "stdio",
    ]
    
    payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "run_python_code",
            "arguments": {
                "python_code": code
            }
        },
        "id": 1,
    }
    
    payload_str = json.dumps(payload)
    
    result = subprocess.run(
        deno_args,
        input=payload_str.encode(),
        capture_output=True,
        check=True,
    )
    
    response = json.loads(result.stdout.decode())
    
    if "error" in response:
        print(f"Error: {response['error']}", file=sys.stderr)
        return None
    
    xml_content = response["result"]["content"][0]["text"]
    print(xml_content)
    return xml_content

if __name__ == "__main__":
    # Example: Run each of our algorithms
    print("=== Testing Factorial Algorithm ===")
    run_algorithm("factorial", "factorial_iterative", 5)
    
    print("\n=== Testing Fibonacci Algorithm ===")
    run_algorithm("fibonacci", "fib_iterative", 10)
    
    print("\n=== Testing Prime Number Algorithm ===")
    run_algorithm("primes", "is_prime_optimized", 17)