#!/usr/bin/env python3
"""
Test access to system resources inside vs. outside the MCP sandbox
"""

import os
import sys
import json
import platform

# Initialize results dictionary
results = {
    "test_name": "system_resources",
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

# Test 1: Get system information
try:
    system_info = {
        "system": platform.system(),
        "node": platform.node(),
        "release": platform.release(),
        "version": platform.version(),
        "machine": platform.machine(),
        "processor": platform.processor()
    }
    results["tests"]["system_info"] = {
        "success": True,
        "result": system_info,
        "error": None
    }
except Exception as e:
    results["tests"]["system_info"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 2: Try to access process information
try:
    import psutil
    process_count = len(psutil.pids())
    memory_info = dict(psutil.virtual_memory()._asdict())
    results["tests"]["process_info"] = {
        "success": True,
        "result": {
            "process_count": process_count,
            "memory_info": {k: v for k, v in memory_info.items() if k in ["total", "available", "percent"]}
        },
        "error": None
    }
except ImportError:
    results["tests"]["process_info"] = {
        "success": False,
        "result": None,
        "error": "psutil module not available"
    }
except Exception as e:
    results["tests"]["process_info"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 3: Try to access current process environment
try:
    # Just get a few environment variables for demonstration
    env_vars = {k: os.environ.get(k) for k in ["USER", "HOME", "PATH", "PYTHONPATH"]}
    results["tests"]["environment_variables"] = {
        "success": True,
        "result": env_vars,
        "error": None
    }
except Exception as e:
    results["tests"]["environment_variables"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 4: Try to load system-specific modules
system_modules = ["sys", "os.path", "ctypes", "signal"]
for module in system_modules:
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

# Output results in JSON format
print(json.dumps(results, indent=2))

# Also save results to a file if run directly
if __name__ == "__main__":
    try:
        with open('results/system_resources_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print("\nResults saved to 'results/system_resources_results.json'")
    except Exception as e:
        print(f"\nFailed to save results: {e}")
