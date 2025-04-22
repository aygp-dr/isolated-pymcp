"""
Running Python code with dependencies using MCP.
"""
import subprocess
import json
import sys
from tempfile import NamedTemporaryFile

def run_with_metadata(code, metadata=None):
    """Run Python code with dependency metadata."""
    if metadata is None:
        metadata = {}
    
    with NamedTemporaryFile("w", suffix=".py") as f:
        # Add metadata block if needed
        if metadata:
            f.write("# /// script\n")
            for k, v in metadata.items():
                f.write(f"# {k} = {v!r}\n")
            f.write("# ///\n\n")
        
        # Write the actual code
        f.write(code)
        f.flush()
        
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
                    "python_code": open(f.name).read()
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
    # Example with numpy dependency
    code = """
import numpy as np

a = np.array([1, 2, 3])
print("NumPy array:")
print(a)

# Matrix multiplication
b = np.array([[1, 2], [3, 4]])
c = np.array([[5, 6], [7, 8]])
print("\nMatrix multiplication:")
print(b @ c)

# Return the result
b @ c
"""
    
    metadata = {
        "dependencies": ["numpy"]
    }
    
    print("Running code with NumPy dependency...")
    run_with_metadata(code, metadata)