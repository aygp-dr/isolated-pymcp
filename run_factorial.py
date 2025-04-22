#!/usr/bin/env python3
from inline_script_metadata import run_with_metadata

code = """
import sys
sys.path.append('.')
from algorithms.factorial import factorial_iterative, factorial_recursive

def test_factorial(n):
    print(f"Testing factorial with n={n}")
    print(f"Iterative approach: {n}! = {factorial_iterative(n)}")
    print(f"Recursive approach: {n}! = {factorial_recursive(n)}")
    print()

# Test with different inputs
for i in range(5, 11):
    test_factorial(i)

# Return the result for n=10
factorial_iterative(10)
"""

# Run the code without additional dependencies
result = run_with_metadata(code)
print("\nResult processed successfully!")