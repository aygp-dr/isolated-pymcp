"""
Tests for Factorial implementations
"""

import pytest
from algorithms.factorial import (
    factorial_recursive,
    factorial_tail_recursive,
    factorial_memoized,
    factorial_iterative,
    factorial_math,
)


# Known factorial values for testing
FACTORIAL_VALUES = [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800]


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 1),
        (1, 1),
        (2, 2),
        (3, 6),
        (4, 24),
        (5, 120),
        (6, 720),
        (7, 5040),
        (8, 40320),
        (9, 362880),
        (10, 3628800),
    ],
)
def test_factorial_recursive(n, expected):
    """Test recursive implementation of factorial."""
    assert factorial_recursive(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 1),
        (1, 1),
        (2, 2),
        (5, 120),
        (10, 3628800),
    ],
)
def test_factorial_tail_recursive(n, expected):
    """Test tail-recursive implementation of factorial."""
    assert factorial_tail_recursive(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 1),
        (1, 1),
        (2, 2),
        (5, 120),
        (10, 3628800),
        (15, 1307674368000),
    ],
)
def test_factorial_memoized(n, expected):
    """Test memoized implementation of factorial."""
    assert factorial_memoized(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 1),
        (1, 1),
        (2, 2),
        (5, 120),
        (10, 3628800),
        (15, 1307674368000),
    ],
)
def test_factorial_iterative(n, expected):
    """Test iterative implementation of factorial."""
    assert factorial_iterative(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (0, 1),
        (1, 1),
        (2, 2),
        (5, 120),
        (10, 3628800),
        (15, 1307674368000),
    ],
)
def test_factorial_math(n, expected):
    """Test math module implementation of factorial."""
    assert factorial_math(n) == expected


def test_factorial_implementations_consistency():
    """Test that all implementations produce the same results."""
    for n in range(10):
        recursive = factorial_recursive(n)
        tail_recursive = factorial_tail_recursive(n)
        memoized = factorial_memoized(n)
        iterative = factorial_iterative(n)
        math_impl = factorial_math(n)

        assert recursive == tail_recursive == memoized == iterative == math_impl


@pytest.mark.parametrize(
    "func",
    [
        factorial_memoized,
        factorial_iterative,
        factorial_math,
    ],
)
def test_factorial_large_n(func):
    """Test factorial implementations with larger inputs."""
    # Skip recursive implementation for large n due to stack overflow risk
    n = 20
    expected = 2432902008176640000
    assert func(n) == expected
