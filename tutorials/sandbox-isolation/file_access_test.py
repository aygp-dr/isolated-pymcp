#!/usr/bin/env python3
"""
Test file system access inside vs. outside the MCP sandbox
"""

import os
import sys
import json

# Initialize results dictionary
results = {
    "test_name": "file_system_access",
    "environment": "unknown",
    "tests": {}
}

# Determine if we're running in MCP sandbox
try:
    # Check for environment markers that might indicate we're in an isolated environment
    if "PYODIDE_ROOT" in os.environ or "PYTHONPATH" in os.environ and "pyodide" in os.environ.get("PYTHONPATH", ""):
        results["environment"] = "mcp_sandbox"
    else:
        results["environment"] = "direct_execution"
except Exception:
    pass

# Test 1: Try to read /etc/passwd
try:
    with open('/etc/passwd', 'r') as f:
        first_line = f.readline().strip()
        results["tests"]["read_etc_passwd"] = {
            "success": True,
            "result": first_line,
            "error": None
        }
except Exception as e:
    results["tests"]["read_etc_passwd"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 2: Try to list files in /home
try:
    home_files = os.listdir('/home')
    results["tests"]["list_home_directory"] = {
        "success": True,
        "result": home_files[:5],  # First 5 items to keep output manageable
        "error": None
    }
except Exception as e:
    results["tests"]["list_home_directory"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 3: Try to get current user info
try:
    import pwd
    current_user = pwd.getpwuid(os.getuid())
    user_info = {
        "name": current_user.pw_name,
        "uid": current_user.pw_uid,
        "gid": current_user.pw_gid,
        "home": current_user.pw_dir
    }
    results["tests"]["get_user_info"] = {
        "success": True,
        "result": user_info,
        "error": None
    }
except Exception as e:
    results["tests"]["get_user_info"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 4: Try to write to a system directory
try:
    with open('/tmp/sandbox_test.txt', 'w') as f:
        f.write('This is a test')
    results["tests"]["write_to_tmp"] = {
        "success": True,
        "result": "Successfully wrote to /tmp/sandbox_test.txt",
        "error": None
    }
    # Clean up
    os.remove('/tmp/sandbox_test.txt')
except Exception as e:
    results["tests"]["write_to_tmp"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Output results in JSON format
print(json.dumps(results, indent=2))

# Also save results to a file if run directly
if __name__ == "__main__":
    try:
        # Attempt to save results to the expected directory
        with open('results/file_access_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print("\nResults saved to 'results/file_access_results.json'")
    except Exception as e:
        print(f"\nFailed to save results: {e}")
