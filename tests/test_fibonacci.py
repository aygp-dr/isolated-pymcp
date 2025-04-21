"""
Tests for Fibonacci implementations
"""

import pytest
from algorithms.fibonacci import fib_recursive, fib_memoized, fib_iterative, fib_generator


# Known Fibonacci numbers for testing
FIB_NUMBERS = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 0),
        (1, 1),
        (2, 1),
        (3, 2),
        (4, 3),
        (5, 5),
        (6, 8),
        (7, 13),
        (8, 21),
        (9, 34),
        (10, 55),
    ],
)
def test_fib_recursive(n, expected):
    """Test recursive implementation of Fibonacci."""
    assert fib_recursive(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 0),
        (1, 1),
        (2, 1),
        (10, 55),
        (20, 6765),
    ],
)
def test_fib_memoized(n, expected):
    """Test memoized implementation of Fibonacci."""
    assert fib_memoized(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 0),
        (1, 1),
        (2, 1),
        (10, 55),
        (20, 6765),
    ],
)
def test_fib_iterative(n, expected):
    """Test iterative implementation of Fibonacci."""
    assert fib_iterative(n) == expected


def test_fib_generator():
    """Test generator implementation of Fibonacci."""
    # Test for n=10
    n = 10
    fib_seq = list(fib_generator(n))

    # Check sequence length
    assert len(fib_seq) == n + 1

    # Check sequence values
    for i, val in enumerate(fib_seq):
        if i < len(FIB_NUMBERS):
            assert val == FIB_NUMBERS[i]


def test_fib_implementations_consistency():
    """Test that all implementations produce the same results."""
    for n in range(10):
        recursive = fib_recursive(n)
        memoized = fib_memoized(n)
        iterative = fib_iterative(n)
        generator = list(fib_generator(n))[-1]

        assert recursive == memoized == iterative == generator


@pytest.mark.parametrize(
    "func",
    [
        fib_memoized,
        fib_iterative,
    ],
)
def test_fibonacci_large_n(func):
    """Test Fibonacci implementations with larger inputs."""
    # Skip recursive implementation for large n as it would be too slow
    n = 35
    assert func(n) == 9227465
