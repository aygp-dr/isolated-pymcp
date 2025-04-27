#!/usr/bin/env python3
"""
Simple test script for pydantic-run-python MCP.
"""
import subprocess
import json
import sys

def run_simple_code():
    """Run a simple Python code snippet."""
    code = """
print("Hello from MCP Run Python!")
result = 40 + 2
print(f"The answer is: {result}")
result
"""
    
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
    
    print(f"Sending payload: {payload_str}")
    
    try:
        result = subprocess.run(
            deno_args,
            input=payload_str.encode(),
            capture_output=True,
            check=True,
        )
        
        stdout = result.stdout.decode()
        stderr = result.stderr.decode()
        
        print(f"STDOUT: {stdout}")
        print(f"STDERR: {stderr}")
        
        if stdout:
            try:
                response = json.loads(stdout)
                if "result" in response:
                    print(f"Success! Result: {response['result']['content'][0]['text']}")
                elif "error" in response:
                    print(f"Error: {response['error']}")
                else:
                    print(f"Unexpected response structure: {response}")
            except json.JSONDecodeError as e:
                print(f"JSON decode error: {e}")
                print(f"Raw output: {stdout}")
        else:
            print("No output received")
            
    except subprocess.CalledProcessError as e:
        print(f"Process error: {e}")
        print(f"STDOUT: {e.stdout.decode() if e.stdout else 'None'}")
        print(f"STDERR: {e.stderr.decode() if e.stderr else 'None'}")

if __name__ == "__main__":
    run_simple_code()