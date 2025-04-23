"""
Fuzz testing for algorithms

This module contains fuzz tests that explore edge cases and unexpected inputs.
"""

import pytest
import random

from algorithms.fibonacci import fib_iterative
from algorithms.factorial import factorial_iterative
from algorithms.primes import is_prime_optimized


class TestFuzzFibonacci:
    """Fuzz tests for Fibonacci implementation."""
    
    def test_fibonacci_negative_input(self) -> None:
        """Test that Fibonacci handles negative inputs gracefully."""
        for _ in range(100):
            n = -random.randint(1, 1000)
            with pytest.raises(ValueError, match="Input must be non-negative"):
                fib_iterative(n)
    
    def test_fibonacci_large_inputs(self) -> None:
        """Test Fibonacci with large inputs."""
        # Choose random large numbers under a threshold that won't cause timeouts
        for _ in range(10):
            n = random.randint(100, 200)
            # This shouldn't crash, but will return a large number
            result = fib_iterative(n)
            assert isinstance(result, int)
            assert result > 0


class TestFuzzFactorial:
    """Fuzz tests for factorial implementation."""
    
    def test_factorial_negative_input(self) -> None:
        """Test that factorial handles negative inputs gracefully."""
        for _ in range(100):
            n = -random.randint(1, 1000)
            with pytest.raises(ValueError, match="Input must be non-negative"):
                factorial_iterative(n)
    
    def test_factorial_large_inputs(self) -> None:
        """Test factorial with inputs that might cause overflow."""
        # Choose a threshold where we expect the function to still work
        threshold = 20  # Factorial grows very quickly
        for _ in range(5):
            n = random.randint(15, threshold)
            result = factorial_iterative(n)
            assert isinstance(result, int)
            assert result > 0


class TestFuzzPrimes:
    """Fuzz tests for prime testing implementations."""
    
    def test_primality_edge_cases(self) -> None:
        """Test primality functions with edge cases."""
        edge_cases = [0, 1, 2, 3, 2**31-1]  # Include Mersenne primes and common edge cases
        
        for n in edge_cases:
            if n < 0:
                with pytest.raises(ValueError):
                    is_prime_optimized(n)
            else:
                # Function should run without error
                result = is_prime_optimized(n)
                assert isinstance(result, bool)
    
    def test_primality_random_large_numbers(self) -> None:
        """Test primality functions with random large numbers."""
        for _ in range(10):
            # Choose random large numbers
            n = random.randint(10**6, 10**6 + 1000)
            
            # Function should handle large numbers without crashing
            result = is_prime_optimized(n)
            assert isinstance(result, bool)


# Define a basic fuzzing test harness
def basic_fuzz_test(func, input_generator, num_tests=100) -> None:
    """
    Run basic fuzz testing on a function.
    
    Args:
        func: Function to test
        input_generator: Function that generates random inputs
        num_tests: Number of test cases to run
    """
    for _ in range(num_tests):
        try:
            inp = input_generator()
            func(inp)  # Should not crash
        except ValueError:
            # ValueError is acceptable for invalid inputs
            pass
        except Exception as e:
            pytest.fail(f"Function crashed with {type(e).__name__}: {e} for input {inp}")


def test_fuzzing_all_functions() -> None:
    """Run basic fuzzing on all numerical functions."""
    # Test fibonacci with various inputs
    basic_fuzz_test(
        lambda n: fib_iterative(n) if n >= 0 else None,
        lambda: random.randint(-10, 50)
    )
    
    # Test factorial with various inputs
    basic_fuzz_test(
        lambda n: factorial_iterative(n) if n >= 0 else None,
        lambda: random.randint(-10, 20)
    )
    
    # Test primality with various inputs
    basic_fuzz_test(
        lambda n: is_prime_optimized(n) if n >= 0 else None,
        lambda: random.randint(-10, 10000)
    )