#!/usr/bin/env python3
"""
Module for executing Python code with metadata through MCP.

This module provides functionality to run Python code with associated metadata
through the Model Context Protocol (MCP) using Deno as the runtime environment.
"""
import json
import subprocess
import sys
from tempfile import NamedTemporaryFile
from typing import Dict, Optional, Any


def run_with_metadata(code: str, metadata: Optional[Dict[str, Any]] = None) -> Optional[str]:
    """
    Execute Python code with optional metadata through MCP.

    This function creates a temporary Python file with the provided code and metadata,
    then executes it using the MCP Python runner via Deno.

    Time complexity: O(1) for function execution, dependent on code complexity
    Space complexity: O(n) where n is the size of the code and metadata

    Args:
        code: Python code to execute
        metadata: Optional dictionary of metadata to include (e.g., dependencies)

    Returns:
        The XML content response from MCP execution, or None if an error occurred
    """
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
    # Example usage
    example_code = """
    import numpy as np
    
    a = np.array([1, 2, 3])
    print(a)
    a
    """
    example_metadata = {
        "dependencies": ["numpy"]
    }
    
    run_with_metadata(example_code, example_metadata)