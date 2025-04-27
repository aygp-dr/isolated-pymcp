#!/usr/bin/env python3
"""
Test command execution capabilities inside vs. outside the MCP sandbox
"""

import os
import sys
import json
import subprocess

# Initialize results dictionary
results = {
    "test_name": "command_execution",
    "environment": "unknown",
    "tests": {}
}

# Determine if we're running in MCP sandbox
try:
    # Check for environment markers
    if "PYODIDE_ROOT" in os.environ or "PYTHONPATH" in os.environ and "pyodide" in os.environ.get("PYTHONPATH", ""):
        results["environment"] = "mcp_sandbox"
    else:
        results["environment"] = "direct_execution"
except Exception:
    pass

# Test 1: Try to execute a command using subprocess
try:
    output = subprocess.check_output(["whoami"], text=True).strip()
    results["tests"]["subprocess_whoami"] = {
        "success": True,
        "result": output,
        "error": None
    }
except Exception as e:
    results["tests"]["subprocess_whoami"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 2: Try to execute a command using os.system
try:
    exit_code = os.system("uname -a > /tmp/uname_output.txt")
    if exit_code == 0:
        with open("/tmp/uname_output.txt", "r") as f:
            output = f.read().strip()
        results["tests"]["os_system_uname"] = {
            "success": True,
            "result": output,
            "error": None
        }
        # Clean up
        os.remove("/tmp/uname_output.txt")
    else:
        results["tests"]["os_system_uname"] = {
            "success": False,
            "result": None,
            "error": f"Command failed with exit code {exit_code}"
        }
except Exception as e:
    results["tests"]["os_system_uname"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 3: Try to execute potentially dangerous command
try:
    # This just lists processes, but in a real attack might do something harmful
    output = subprocess.check_output(["ps", "aux"], text=True)
    results["tests"]["subprocess_ps_aux"] = {
        "success": True,
        "result": "Output too long to display",
        "error": None
    }
except Exception as e:
    results["tests"]["subprocess_ps_aux"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 4: Try to load a command execution library
try:
    import pty
    results["tests"]["import_pty"] = {
        "success": True,
        "result": "Successfully imported pty module",
        "error": None
    }
except Exception as e:
    results["tests"]["import_pty"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Output results in JSON format
print(json.dumps(results, indent=2))

# Also save results to a file if run directly
if __name__ == "__main__":
    try:
        with open('results/command_execution_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print("\nResults saved to 'results/command_execution_results.json'")
    except Exception as e:
        print(f"\nFailed to save results: {e}")
