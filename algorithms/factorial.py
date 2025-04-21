#!/usr/bin/env python3
"""
Implementations of factorial calculation

This module provides various implementations of the factorial function
to demonstrate different approaches and their performance characteristics.
"""
import math
import time
from functools import lru_cache
from typing import List


def factorial_recursive(n: int) -> int:
    """
    Recursive implementation of factorial.
    
    Time complexity: O(n)
    Space complexity: O(n) due to recursion stack
    
    Args:
        n: Number to calculate factorial of
        
    Returns:
        n! (n factorial)
    """
    if n <= 1:
        return 1
    return n * factorial_recursive(n - 1)


def factorial_tail_recursive(n: int, acc: int = 1) -> int:
    """
    Tail-recursive implementation of factorial.
    
    Note: Python doesn't optimize tail recursion, so this still has
    O(n) space complexity due to the recursion stack.
    
    Args:
        n: Number to calculate factorial of
        acc: Accumulator for the result
        
    Returns:
        n! (n factorial)
    """
    if n <= 1:
        return acc
    return factorial_tail_recursive(n - 1, n * acc)


@lru_cache(maxsize=None)
def factorial_memoized(n: int) -> int:
    """
    Memoized recursive implementation of factorial.
    
    Time complexity: O(n) for first call, O(1) for repeated calls
    Space complexity: O(n)
    
    Args:
        n: Number to calculate factorial of
        
    Returns:
        n! (n factorial)
    """
    if n <= 1:
        return 1
    return n * factorial_memoized(n - 1)


def factorial_iterative(n: int) -> int:
    """
    Iterative implementation of factorial.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        n: Number to calculate factorial of
        
    Returns:
        n! (n factorial)
    """
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def factorial_math(n: int) -> int:
    """
    Implementation using Python's math.factorial.
    
    Args:
        n: Number to calculate factorial of
        
    Returns:
        n! (n factorial)
    """
    return math.factorial(n)


def benchmark_factorial(n: int) -> None:
    """
    Benchmark different factorial implementations.
    
    Args:
        n: Number to calculate factorial of
    """
    print(f"Benchmarking factorial implementations for n={n}")
    
    # Recursive
    start = time.time()
    result = factorial_recursive(n)
    end = time.time()
    print(f"Recursive:      {result} (Time: {end - start:.6f}s)")
    
    # Tail recursive
    start = time.time()
    result = factorial_tail_recursive(n)
    end = time.time()
    print(f"Tail Recursive: {result} (Time: {end - start:.6f}s)")
    
    # Memoized
    start = time.time()
    result = factorial_memoized(n)
    end = time.time()
    print(f"Memoized:       {result} (Time: {end - start:.6f}s)")
    
    # Iterative
    start = time.time()
    result = factorial_iterative(n)
    end = time.time()
    print(f"Iterative:      {result} (Time: {end - start:.6f}s)")
    
    # Math module
    start = time.time()
    result = factorial_math(n)
    end = time.time()
    print(f"Math Module:    {result} (Time: {end - start:.6f}s)")


if __name__ == "__main__":
    # Test for a moderate value
    value = 20
    print(f"Factorial of {value}:")
    print(f"Result: {factorial_iterative(value)}")
    
    # Benchmark
    benchmark_factorial(value)
