#!/usr/bin/env python3
"""
Implementations of prime number algorithms

This module provides various implementations of prime number algorithms
to demonstrate different approaches and their performance characteristics.
"""
import math
import time
from typing import List


def is_prime_naive(n: int) -> bool:
    """
    Naive implementation to check if a number is prime.

    Checks all numbers from 2 to n-1 as potential divisors.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        n: Number to check for primality

    Returns:
        True if n is prime, False otherwise
    """
    if n <= 1:
        return False

    for i in range(2, n):
        if n % i == 0:
            return False

    return True


def is_prime_optimized(n: int) -> bool:
    """
    Optimized implementation to check if a number is prime.

    Checks numbers from 2 to sqrt(n) as potential divisors.

    Time complexity: O(sqrt(n))
    Space complexity: O(1)

    Args:
        n: Number to check for primality

    Returns:
        True if n is prime, False otherwise
    """
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False

    # Check divisibility by numbers of form 6k ± 1 up to sqrt(n)
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6

    return True


def primes_up_to(n: int) -> List[int]:
    """
    Generate a list of all primes up to n using trial division.

    Time complexity: O(n * sqrt(n))
    Space complexity: O(n)

    Args:
        n: Upper limit for prime number generation

    Returns:
        List of all prime numbers <= n
    """
    return [i for i in range(2, n + 1) if is_prime_optimized(i)]


def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Generate a list of all primes up to n using the Sieve of Eratosthenes.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    Args:
        n: Upper limit for prime number generation

    Returns:
        List of all prime numbers <= n
    """
    # Initialize the sieve
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False

    # Mark non-primes using Sieve of Eratosthenes
    for i in range(2, int(math.sqrt(n)) + 1):
        if sieve[i]:
            # Mark all multiples of i as non-prime
            for j in range(i * i, n + 1, i):
                sieve[j] = False

    # Return all primes
    return [i for i in range(2, n + 1) if sieve[i]]


def segmented_sieve(n: int, segment_size: int = 10000) -> List[int]:
    """
    Generate primes up to n using a segmented Sieve of Eratosthenes.

    This implementation uses less memory for large values of n by
    dividing the range into segments.

    Time complexity: O(n log log n)
    Space complexity: O(sqrt(n) + segment_size)

    Args:
        n: Upper limit for prime number generation
        segment_size: Size of segments to process

    Returns:
        List of all prime numbers <= n
    """
    # Get small primes up to sqrt(n) to use for sieving
    limit = int(math.sqrt(n)) + 1
    base_primes = sieve_of_eratosthenes(limit)

    # Initialize result with base primes
    primes = base_primes.copy()

    # Process segments
    for low in range(limit + 1, n + 1, segment_size):
        high = min(low + segment_size - 1, n)

        # Initialize segment
        segment = [True] * (high - low + 1)

        # Sieve segment using base primes
        for prime in base_primes:
            # Find the first multiple of prime in the segment
            start = max(prime * prime, (low + prime - 1) // prime * prime)

            # Mark all multiples of prime in segment as non-prime
            for j in range(start, high + 1, prime):
                segment[j - low] = False

        # Collect primes from segment
        for i in range(len(segment)):
            if segment[i]:
                primes.append(i + low)

    return primes


def benchmark_prime_algorithms(n: int) -> None:
    """
    Benchmark different prime number algorithms.

    Args:
        n: Upper limit for prime number generation
    """
    print(f"Benchmarking prime number algorithms up to n={n}")

    # Check if a specific number is prime
    test_value = n - 1

    start = time.time()
    result = is_prime_naive(test_value)
    end = time.time()
    print(f"is_prime_naive({test_value}): {result} (Time: {end - start:.6f}s)")

    start = time.time()
    result = is_prime_optimized(test_value)
    end = time.time()
    print(f"is_prime_optimized({test_value}): {result} (Time: {end - start:.6f}s)")

    # Generate primes up to n
    if n <= 100000:  # Only run for smaller values
        start = time.time()
        primes_list = primes_up_to(n)
        end = time.time()
        print(f"primes_up_to({n}): Found {len(primes_list)} primes (Time: {end - start:.6f}s)")

    start = time.time()
    sieve_list = sieve_of_eratosthenes(n)
    end = time.time()
    print(f"sieve_of_eratosthenes({n}): Found {len(sieve_list)} primes (Time: {end - start:.6f}s)")

    start = time.time()
    segmented_list = segmented_sieve(n)
    end = time.time()
    print(f"segmented_sieve({n}): Found {len(segmented_list)} primes (Time: {end - start:.6f}s)")


if __name__ == "__main__":
    # Display primes up to 50
    limit = 50
    print(f"Primes up to {limit}:")
    print(sieve_of_eratosthenes(limit))

    # Benchmark
    benchmark_prime_algorithms(1000000)
