#!/bin/bash
# Run tests through the MCP sandbox using Claude CLI

echo "Running isolation tests through the MCP sandbox..."

# Create results directory
mkdir -p results

# Run each test through the MCP sandbox via Claude CLI
echo "Running file access test through MCP..."
cat <<EOF | claude -p "Run this Python code using the pydantic-run-python MCP server. Only provide the raw output without any additional commentary." > results/file_access_results_mcp.json
import os
import sys
import json

# Initialize results dictionary
results = {
    "test_name": "file_system_access",
    "environment": "mcp_sandbox",
    "tests": {}
}

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
EOF

echo "Running command execution test through MCP..."
cat <<EOF | claude -p "Run this Python code using the pydantic-run-python MCP server. Only provide the raw output without any additional commentary." > results/command_execution_results_mcp.json
import os
import sys
import json
import subprocess

# Initialize results dictionary
results = {
    "test_name": "command_execution",
    "environment": "mcp_sandbox",
    "tests": {}
}

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
EOF

echo "Running network access test through MCP..."
cat <<EOF | claude -p "Run this Python code using the pydantic-run-python MCP server. Only provide the raw output without any additional commentary." > results/network_access_results_mcp.json
import os
import sys
import json
import socket

# Initialize results dictionary
results = {
    "test_name": "network_access",
    "environment": "mcp_sandbox",
    "tests": {}
}

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
EOF

echo "Running system resources test through MCP..."
cat <<EOF | claude -p "Run this Python code using the pydantic-run-python MCP server. Only provide the raw output without any additional commentary." > results/system_resources_results_mcp.json
import os
import sys
import json
import platform

# Initialize results dictionary
results = {
    "test_name": "system_resources",
    "environment": "mcp_sandbox",
    "tests": {}
}

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
EOF

echo -e "\nMCP sandbox tests completed."
