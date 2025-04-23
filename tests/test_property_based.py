"""
Property-based tests for algorithms

This module contains property-based tests for the algorithms in the project.
It uses the hypothesis library to generate test cases.
"""

import pytest
from hypothesis import given, strategies as st, assume, settings, example

from algorithms.fibonacci import fib_recursive, fib_memoized, fib_iterative
from algorithms.factorial import factorial_recursive, factorial_iterative, factorial_math
from algorithms.primes import is_prime_naive, is_prime_optimized, sieve_of_eratosthenes


class TestFibonacciProperties:
    """Property-based tests for Fibonacci algorithms."""

    @given(st.integers(min_value=0, max_value=10))
    def test_fibonacci_recurrence_relation(self, n: int) -> None:
        """Test the fundamental recurrence relation of Fibonacci numbers."""
        if n >= 2:
            assert fib_iterative(n) == fib_iterative(n - 1) + fib_iterative(n - 2)

    @given(st.integers(min_value=0, max_value=20))
    def test_fibonacci_non_negative(self, n: int) -> None:
        """Test that all Fibonacci numbers are non-negative."""
        assert fib_iterative(n) >= 0

    @given(st.integers(min_value=3, max_value=20))
    def test_fibonacci_strictly_increasing(self, n: int) -> None:
        """Test that Fibonacci sequence is strictly increasing after F(2)."""
        assert fib_iterative(n) > fib_iterative(n - 1)


class TestFactorialProperties:
    """Property-based tests for factorial algorithms."""

    @given(st.integers(min_value=0, max_value=10))
    def test_factorial_recurrence_relation(self, n: int) -> None:
        """Test the fundamental recurrence relation of factorial."""
        if n >= 1:
            assert factorial_iterative(n) == n * factorial_iterative(n - 1)

    @given(st.integers(min_value=0, max_value=10))
    def test_factorial_positive(self, n: int) -> None:
        """Test that all factorial values are positive."""
        assert factorial_iterative(n) > 0

    @given(st.integers(min_value=1, max_value=10))
    def test_factorial_strictly_increasing(self, n: int) -> None:
        """Test that factorial sequence is strictly increasing."""
        assert factorial_iterative(n) > factorial_iterative(n - 1)

    @given(st.integers(min_value=0, max_value=5))
    def test_factorial_implementations_equivalence(self, n: int) -> None:
        """Test that all factorial implementations give equivalent results."""
        result_recursive = factorial_recursive(n)
        result_iterative = factorial_iterative(n)
        result_math = factorial_math(n)
        
        assert result_recursive == result_iterative == result_math


class TestPrimeProperties:
    """Property-based tests for prime number algorithms."""

    @given(st.integers(min_value=2, max_value=1000))
    def test_primality_test_consistency(self, n: int) -> None:
        """Test that both primality test implementations agree."""
        assert is_prime_naive(n) == is_prime_optimized(n)

    @given(st.integers(min_value=2, max_value=100))
    def test_prime_divisibility(self, n: int) -> None:
        """Test the fundamental property of prime numbers."""
        if is_prime_optimized(n):
            # If n is prime, it should have no divisors other than 1 and itself
            for i in range(2, n):
                assert n % i != 0
        else:
            # If n is not prime, it should have at least one divisor other than 1 and itself
            has_divisor = False
            for i in range(2, n):
                if n % i == 0:
                    has_divisor = True
                    break
            assert has_divisor

    @given(st.integers(min_value=2, max_value=100))
    @example(2)  # Ensure we test the smallest prime
    def test_sieve_correctness(self, n: int) -> None:
        """Test that the sieve correctly identifies all primes up to n."""
        primes = sieve_of_eratosthenes(n)
        
        # All numbers in the result should be prime
        for p in primes:
            assert is_prime_optimized(p)
            
        # All primes up to n should be in the result
        for i in range(2, n + 1):
            if is_prime_optimized(i):
                assert i in primes


class TestCrossAlgorithmProperties:
    """Tests for properties that relate different algorithms."""

    @given(st.integers(min_value=0, max_value=10))
    def test_fibonacci_factorial_relationship(self, n: int) -> None:
        """Test an interesting mathematical relationship between Fibonacci and factorial."""
        # Skip for n=0 since the relationship doesn't hold
        if n > 0:
            # For small n, fib(n+1) ≤ factorial(n) for all n ≥ 1
            assert fib_iterative(n + 1) <= factorial_iterative(n)