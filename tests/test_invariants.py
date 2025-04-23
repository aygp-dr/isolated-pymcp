"""
Invariant tests for algorithms

This module tests mathematical invariants and identities for our algorithms.
"""

import pytest
import math
from typing import List

from algorithms.fibonacci import fib_iterative, fib_generator
from algorithms.factorial import factorial_iterative
from algorithms.primes import is_prime_optimized, sieve_of_eratosthenes


class TestFibonacciInvariants:
    """Tests for mathematical invariants of Fibonacci numbers."""
    
    def test_golden_ratio_approximation(self) -> None:
        """
        Test that the ratio of consecutive Fibonacci numbers approximates the golden ratio.
        As n increases, the ratio F(n+1)/F(n) should approach φ = (1+√5)/2 ≈ 1.618033988749895
        """
        golden_ratio = (1 + math.sqrt(5)) / 2  # Approximately 1.618033988749895
        
        # For larger n values, the approximation gets better
        n = 30
        ratio = fib_iterative(n + 1) / fib_iterative(n)
        
        # Check that the approximation is within a small epsilon
        assert abs(ratio - golden_ratio) < 1e-10
    
    def test_binet_formula(self) -> None:
        """
        Test Binet's formula for calculating the nth Fibonacci number:
        F(n) = (φ^n - (1-φ)^n)/√5
        """
        phi = (1 + math.sqrt(5)) / 2
        
        for n in range(0, 20):
            # Calculate F(n) using Binet's formula
            binet = int(round((phi**n - (1-phi)**n) / math.sqrt(5)))
            
            # Compare with the iterative implementation
            assert binet == fib_iterative(n)
    
    def test_sum_of_squares(self) -> None:
        """
        Test the identity: F(0)² + F(1)² + ... + F(n)² = F(n)×F(n+1)
        """
        for n in range(1, 15):
            # Get all Fibonacci numbers up to F(n)
            fibs = list(fib_generator(n))
            
            # Calculate the sum of squares
            sum_of_squares = sum(f**2 for f in fibs)
            
            # Calculate F(n)×F(n+1)
            product = fib_iterative(n) * fib_iterative(n + 1)
            
            assert sum_of_squares == product


class TestFactorialInvariants:
    """Tests for mathematical invariants of factorial functions."""
    
    def test_factorial_stirling_approximation(self) -> None:
        """
        Test Stirling's approximation for factorial:
        n! ≈ √(2πn)(n/e)^n
        """
        for n in range(10, 20):
            # Actual factorial
            actual = factorial_iterative(n)
            
            # Stirling's approximation
            stirling = math.sqrt(2 * math.pi * n) * ((n / math.e) ** n)
            
            # Test that the approximation is within a reasonable margin
            # The larger n is, the better the approximation
            error_margin = 0.01  # 1% error margin
            relative_error = abs(actual - stirling) / actual
            
            assert relative_error < error_margin
    
    def test_factorial_gamma_function(self) -> None:
        """
        Test that factorial(n) = gamma(n+1) for integer n.
        The gamma function extends factorial to non-integer values.
        """
        for n in range(0, 15):
            # Calculate n! using our implementation
            fact = factorial_iterative(n)
            
            # Calculate Γ(n+1) using math.gamma
            gamma = math.gamma(n + 1)
            
            # They should be very close for integers
            assert abs(fact - gamma) < 1e-10


class TestPrimeInvariants:
    """Tests for mathematical invariants of prime numbers."""
    
    def test_primes_asymptotic_density(self) -> None:
        """
        Test the Prime Number Theorem: The number of primes <= n is approximately n/ln(n)
        """
        n = 10000
        primes = sieve_of_eratosthenes(n)
        count = len(primes)
        
        # Prime Number Theorem approximation
        expected = n / math.log(n)
        
        # The approximation should be within a reasonable error margin
        error_margin = 0.1  # 10% error margin
        relative_error = abs(count - expected) / expected
        
        assert relative_error < error_margin
    
    def test_twin_primes(self) -> None:
        """
        Test finding twin primes (primes that differ by 2).
        According to the Twin Prime Conjecture, there should be infinitely many.
        """
        n = 1000
        primes = sieve_of_eratosthenes(n)
        
        # Find twin primes in our list
        twin_primes = []
        for i in range(len(primes) - 1):
            if primes[i + 1] - primes[i] == 2:
                twin_primes.append((primes[i], primes[i + 1]))
        
        # We should find at least a few twin primes in this range
        assert len(twin_primes) > 5
        
        # Verify that each pair is indeed a twin prime
        for p1, p2 in twin_primes:
            assert is_prime_optimized(p1)
            assert is_prime_optimized(p2)
            assert p2 - p1 == 2
    
    def test_prime_factorization_product(self) -> None:
        """
        Test that the product of prime factors of a number equals the number itself.
        """
        def prime_factors(n: int) -> List[int]:
            """Get prime factors of a number."""
            factors = []
            d = 2
            while n > 1:
                while n % d == 0:
                    factors.append(d)
                    n //= d
                d += 1
                if d*d > n and n > 1:
                    factors.append(n)
                    break
            return factors
        
        for n in range(2, 100):
            factors = prime_factors(n)
            product = 1
            for factor in factors:
                product *= factor
            
            assert product == n
            # Also check that all factors are prime
            for factor in factors:
                assert is_prime_optimized(factor)