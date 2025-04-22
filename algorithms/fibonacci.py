#!/usr/bin/env python3
"""
Implementations of the Fibonacci sequence

This module provides various implementations of the Fibonacci sequence
to demonstrate different approaches and their performance characteristics.
"""
from functools import lru_cache
import time
from typing import Generator


def fib_recursive(n: int) -> int:
    """
    Recursive implementation of Fibonacci.

    Time complexity: O(2^n)
    Space complexity: O(n) due to recursion stack

    Args:
        n: Position in the Fibonacci sequence (0-indexed)

    Returns:
        The nth Fibonacci number
    """
    if n <= 1:
        return n
    return fib_recursive(n - 1) + fib_recursive(n - 2)


@lru_cache(maxsize=None)
def fib_memoized(n: int) -> int:
    """
    Memoized recursive implementation of Fibonacci.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        n: Position in the Fibonacci sequence (0-indexed)

    Returns:
        The nth Fibonacci number
    """
    if n <= 1:
        return n
    return fib_memoized(n - 1) + fib_memoized(n - 2)


def fib_iterative(n: int) -> int:
    """
    Iterative implementation of Fibonacci.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        n: Position in the Fibonacci sequence (0-indexed)

    Returns:
        The nth Fibonacci number
    """
    if n <= 1:
        return n

    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def fib_generator(n: int) -> Generator[int, None, None]:
    """
    Generator implementation of Fibonacci sequence.

    Yields the Fibonacci sequence up to the nth number.

    Args:
        n: Number of Fibonacci numbers to generate

    Yields:
        Fibonacci numbers in sequence
    """
    a, b = 0, 1
    yield a

    if n > 0:
        yield b

    for _ in range(2, n + 1):
        a, b = b, a + b
        yield b


def benchmark_fibonacci(n: int) -> None:
    """
    Benchmark different Fibonacci implementations.

    Args:
        n: Position in the Fibonacci sequence to calculate
    """
    print(f"Benchmarking Fibonacci implementations for n={n}")

    # Only benchmark recursive for small values due to exponential growth
    if n <= 30:
        start = time.time()
        result = fib_recursive(n)
        end = time.time()
        print(f"Recursive: {result} (Time: {end - start:.6f}s)")
    else:
        print("Recursive implementation skipped for large n (would take too long)")

    # Memoized version
    start = time.time()
    result = fib_memoized(n)
    end = time.time()
    print(f"Memoized:  {result} (Time: {end - start:.6f}s)")

    # Iterative version
    start = time.time()
    result = fib_iterative(n)
    end = time.time()
    print(f"Iterative: {result} (Time: {end - start:.6f}s)")

    # Generator version (just time to generate full sequence)
    start = time.time()
    result = list(fib_generator(n))[-1]
    end = time.time()
    print(f"Generator: {result} (Time: {end - start:.6f}s)")


if __name__ == "__main__":
    # Test small value
    print("First 10 Fibonacci numbers:")
    print(list(fib_generator(9)))

    # Benchmark
    benchmark_fibonacci(35)
