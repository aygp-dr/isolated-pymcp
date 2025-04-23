#!/usr/bin/env python3
"""
Script to run factorial algorithm examples through MCP.

This script demonstrates executing factorial algorithms through the Model
Context Protocol (MCP) using the inline_script_metadata module.
"""
import sys
from pathlib import Path

# Add scripts directory to path to import inline_script_metadata
sys.path.append(str(Path(__file__).parent))
from inline_script_metadata import run_with_metadata

# Python code that will be executed
code = """
import sys
sys.path.append('.')
from algorithms.factorial import factorial_iterative, factorial_recursive

def test_factorial(n: int) -> None:
    """
    Test factorial implementations with a given input.
    
    Args:
        n: Number to calculate factorial of
    """
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