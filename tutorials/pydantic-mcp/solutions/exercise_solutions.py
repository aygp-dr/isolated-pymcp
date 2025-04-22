"""
Solutions to the workshop exercises.
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

# Exercise 1: Run a data analysis with pandas
def exercise1():
    print("=== Exercise 1: Data Analysis with Pandas ===\n")
    code = """
import pandas as pd
import matplotlib.pyplot as plt
import io
import base64

# Create a sample DataFrame
data = {
    'Year': [2018, 2019, 2020, 2021, 2022],
    'Sales': [150, 200, 180, 250, 300],
    'Expenses': [130, 150, 170, 190, 220]
}

df = pd.DataFrame(data)
print(df)

# Calculate profit
df['Profit'] = df['Sales'] - df['Expenses']
print("\nDataFrame with Profit:")
print(df)

# Summary statistics
print("\nSummary Statistics:")
print(df.describe())

# Return the DataFrame
df
"""
    metadata = {
        "dependencies": ["pandas", "matplotlib"]
    }
    
    run_with_metadata(code, metadata)

# Exercise 2: Run factorial benchmarking
def exercise2():
    print("\n=== Exercise 2: Factorial Benchmarking ===\n")
    code = """
import sys
import time
sys.path.append('.')
from algorithms.factorial import factorial_iterative, factorial_recursive

def benchmark(func, n, iterations=1000):
    start_time = time.time()
    for _ in range(iterations):
        result = func(n)
    end_time = time.time()
    return result, end_time - start_time

print("Benchmarking factorial implementations:")
n_values = [5, 10, 15, 20]

results = []
for n in n_values:
    iter_result, iter_time = benchmark(factorial_iterative, n)
    rec_result, rec_time = benchmark(factorial_recursive, n)
    
    results.append({
        'n': n,
        'iterative_result': iter_result,
        'iterative_time': iter_time,
        'recursive_result': rec_result,
        'recursive_time': rec_time
    })

# Print results
print("\\nResults:")
print(f"{'n':<5} {'Iterative Time':<20} {'Recursive Time':<20} {'Ratio (Rec/Iter)':<20}")
print("-" * 65)

for r in results:
    ratio = r['recursive_time'] / r['iterative_time']
    print(f"{r['n']:<5} {r['iterative_time']:<20.6f} {r['recursive_time']:<20.6f} {ratio:<20.2f}")

# Return the results
results
"""
    
    run_with_metadata(code)

if __name__ == "__main__":
    exercise1()
    exercise2()