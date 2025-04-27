#!/usr/bin/env python3
"""
Test network access capabilities inside vs. outside the MCP sandbox
"""

import os
import sys
import json
import socket

# Initialize results dictionary
results = {
    "test_name": "network_access",
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

# Test 1: Try to resolve a domain name
try:
    ip_address = socket.gethostbyname("www.example.com")
    results["tests"]["dns_lookup"] = {
        "success": True,
        "result": ip_address,
        "error": None
    }
except Exception as e:
    results["tests"]["dns_lookup"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 2: Try to connect to a public website on port 80
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)
    result = s.connect_ex(("www.example.com", 80))
    if result == 0:
        results["tests"]["connect_port_80"] = {
            "success": True,
            "result": "Successfully connected to www.example.com:80",
            "error": None
        }
    else:
        results["tests"]["connect_port_80"] = {
            "success": False,
            "result": None,
            "error": f"Connection failed with error code {result}"
        }
    s.close()
except Exception as e:
    results["tests"]["connect_port_80"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 3: Try to import networking libraries
network_modules = ["requests", "urllib.request", "http.client"]
for module in network_modules:
    try:
        __import__(module)
        results["tests"][f"import_{module.replace('.', '_')}"] = {
            "success": True,
            "result": f"Successfully imported {module}",
            "error": None
        }
    except Exception as e:
        results["tests"][f"import_{module.replace('.', '_')}"] = {
            "success": False,
            "result": None,
            "error": str(e)
        }

# Test 4: Try to open a socket on a local port
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('127.0.0.1', 8888))
    s.listen(1)
    results["tests"]["open_local_socket"] = {
        "success": True,
        "result": "Successfully opened socket on 127.0.0.1:8888",
        "error": None
    }
    s.close()
except Exception as e:
    results["tests"]["open_local_socket"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Output results in JSON format
print(json.dumps(results, indent=2))

# Also save results to a file if run directly
if __name__ == "__main__":
    try:
        with open('results/network_access_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print("\nResults saved to 'results/network_access_results.json'")
    except Exception as e:
        print(f"\nFailed to save results: {e}")
