#!/usr/bin/env python3
"""
Test script attempting to bypass sandbox isolation through various techniques
"""

import os
import sys
import json
import subprocess
import socket
import importlib
import platform
from pathlib import Path

# Initialize results dictionary
results = {
    "test_name": "sandbox_bypass_attempts",
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

# Test 1: Try to use ctypes to call system functions
try:
    import ctypes
    # Try to use libc to execute a system command
    libc = ctypes.CDLL(None)
    libc.system(b"id > /tmp/ctypes_test.txt")
    
    # Check if the file was created
    if os.path.exists("/tmp/ctypes_test.txt"):
        with open("/tmp/ctypes_test.txt", "r") as f:
            output = f.read().strip()
        results["tests"]["ctypes_system_call"] = {
            "success": True,
            "result": output,
            "error": None
        }
        # Clean up
        os.remove("/tmp/ctypes_test.txt")
    else:
        results["tests"]["ctypes_system_call"] = {
            "success": False,
            "result": None,
            "error": "File not created"
        }
except Exception as e:
    results["tests"]["ctypes_system_call"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 2: Try to use eval/exec to execute arbitrary code
try:
    code_to_execute = """
import os
os.system('echo "Eval executed" > /tmp/eval_test.txt')
"""
    exec(code_to_execute)
    
    # Check if the file was created
    if os.path.exists("/tmp/eval_test.txt"):
        with open("/tmp/eval_test.txt", "r") as f:
            output = f.read().strip()
        results["tests"]["exec_code_execution"] = {
            "success": True,
            "result": output,
            "error": None
        }
        # Clean up
        os.remove("/tmp/eval_test.txt")
    else:
        results["tests"]["exec_code_execution"] = {
            "success": False,
            "result": None,
            "error": "File not created"
        }
except Exception as e:
    results["tests"]["exec_code_execution"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 3: Try to access file system via alternate APIs
try:
    from pathlib import Path
    
    # Try to read /etc/passwd using pathlib
    passwd_content = Path('/etc/passwd').read_text().splitlines()[0]
    results["tests"]["pathlib_file_access"] = {
        "success": True,
        "result": passwd_content,
        "error": None
    }
except Exception as e:
    results["tests"]["pathlib_file_access"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 4: Try to use signals module to send signals
try:
    import signal
    
    # Set up a handler for SIGUSR1 to prevent termination
    def signal_handler(signum, frame):
        print(f"Signal {signum} caught")
    
    # Register the handler
    signal.signal(signal.SIGUSR1, signal_handler)
    
    # Try to send a signal to the current process
    os.kill(os.getpid(), signal.SIGUSR1)
    results["tests"]["signal_manipulation"] = {
        "success": True,
        "result": "Successfully sent signal to process",
        "error": None
    }
except Exception as e:
    results["tests"]["signal_manipulation"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 5: Try to dynamically load a C extension module
try:
    # This assumes there's a compiled extension somewhere accessible
    extension_paths = [
        "/usr/local/lib/python3*/site-packages/*.so",
        "/usr/lib/python3*/site-packages/*.so"
    ]
    
    import glob
    found_modules = []
    for pattern in extension_paths:
        found_modules.extend(glob.glob(pattern))
    
    if found_modules:
        # Try to load the first one found
        import importlib.util
        mod_path = found_modules[0]
        mod_name = os.path.basename(mod_path).split('.')[0]
        
        spec = importlib.util.spec_from_file_location(mod_name, mod_path)
        if spec:
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            results["tests"]["load_c_extension"] = {
                "success": True,
                "result": f"Loaded extension module: {mod_path}",
                "error": None
            }
        else:
            results["tests"]["load_c_extension"] = {
                "success": False,
                "result": None,
                "error": "Could not create spec for module"
            }
    else:
        results["tests"]["load_c_extension"] = {
            "success": False,
            "result": None,
            "error": "No extension modules found"
        }
except Exception as e:
    results["tests"]["load_c_extension"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Test 6: Try to use multiprocessing to spawn a new process
try:
    import multiprocessing
    
    def worker_function():
        with open("/tmp/multiprocessing_test.txt", "w") as f:
            f.write("Multiprocessing worker executed")
        return "Worker completed"
    
    # Create and start a process
    process = multiprocessing.Process(target=worker_function)
    process.start()
    process.join(timeout=2)
    
    # Check if the file was created
    if os.path.exists("/tmp/multiprocessing_test.txt"):
        with open("/tmp/multiprocessing_test.txt", "r") as f:
            output = f.read().strip()
        results["tests"]["multiprocessing_execution"] = {
            "success": True,
            "result": output,
            "error": None
        }
        # Clean up
        os.remove("/tmp/multiprocessing_test.txt")
    else:
        results["tests"]["multiprocessing_execution"] = {
            "success": False,
            "result": None,
            "error": "File not created"
        }
except Exception as e:
    results["tests"]["multiprocessing_execution"] = {
        "success": False,
        "result": None,
        "error": str(e)
    }

# Output results in JSON format
print(json.dumps(results, indent=2))

# Also save results to a file if run directly
if __name__ == "__main__":
    try:
        # Create results directory if it doesn't exist
        os.makedirs("results", exist_ok=True)
        
        # Attempt to save results to the expected directory
        with open('results/bypass_attempt_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print("\nResults saved to 'results/bypass_attempt_results.json'")
    except Exception as e:
        print(f"\nFailed to save results: {e}")