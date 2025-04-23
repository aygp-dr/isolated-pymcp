;; Check available modules in Pyodide
(mcp-run-python-code "
import sys
import micropip

# List standard library modules
std_lib = [m for m in sys.modules.keys()]
print('Standard library modules available:', sorted(std_lib)[:10], '...')

# List installed packages
try:
    installed = micropip.list()
    print('\\nInstalled packages:', installed)
except Exception as e:
    print('Error listing packages:', e)

# Check specific modules
modules_to_check = ['numpy', 'pandas', 'matplotlib', 'sympy', 'scipy']
for module in modules_to_check:
    try:
        __import__(module)
        print(f'Module {module} is available')
    except ImportError:
        print(f'Module {module} is NOT available')
")
