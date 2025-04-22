"""
Tests for Prime number implementations
"""

import pytest
from algorithms.primes import (
    is_prime_naive,
    is_prime_optimized,
    primes_up_to,
    sieve_of_eratosthenes,
    segmented_sieve,
)


# Known prime numbers for testing
PRIMES_UNDER_100 = [
    2,
    3,
    5,
    7,
    11,
    13,
    17,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
    53,
    59,
    61,
    67,
    71,
    73,
    79,
    83,
    89,
    97,
]


@pytest.mark.parametrize(
    "n, expected",
    [
        (1, False),  # 1 is not prime
        (2, True),  # 2 is prime
        (3, True),  # 3 is prime
        (4, False),  # 4 is not prime
        (5, True),  # 5 is prime
        (6, False),  # 6 is not prime
        (7, True),  # 7 is prime
        (8, False),  # 8 is not prime
        (9, False),  # 9 is not prime
        (10, False),  # 10 is not prime
        (11, True),  # 11 is prime
        (97, True),  # 97 is prime
        (100, False),  # 100 is not prime
    ],
)
def test_is_prime_naive(n, expected):
    """Test naive primality check."""
    assert is_prime_naive(n) == expected


@pytest.mark.parametrize(
    "n, expected",
    [
        (1, False),  # 1 is not prime
        (2, True),  # 2 is prime
        (3, True),  # 3 is prime
        (4, False),  # 4 is not prime
        (5, True),  # 5 is prime
        (6, False),  # 6 is not prime
        (7, True),  # 7 is prime
        (8, False),  # 8 is not prime
        (9, False),  # 9 is not prime
        (10, False),  # 10 is not prime
        (11, True),  # 11 is prime
        (97, True),  # 97 is prime
        (100, False),  # 100 is not prime
        (997, True),  # 997 is prime
    ],
)
def test_is_prime_optimized(n, expected):
    """Test optimized primality check."""
    assert is_prime_optimized(n) == expected


def test_primes_up_to():
    """Test generation of primes up to a limit using trial division."""
    assert primes_up_to(100) == PRIMES_UNDER_100
    assert len(primes_up_to(1000)) == 168  # There are 168 primes under 1000


def test_sieve_of_eratosthenes():
    """Test Sieve of Eratosthenes implementation."""
    assert sieve_of_eratosthenes(100) == PRIMES_UNDER_100
    assert len(sieve_of_eratosthenes(1000)) == 168


def test_segmented_sieve():
    """Test segmented Sieve of Eratosthenes implementation."""
    assert segmented_sieve(100) == PRIMES_UNDER_100
    assert len(segmented_sieve(1000)) == 168


def test_prime_algorithm_consistency():
    """Test that all prime generation methods produce the same results."""
    limit = 1000

    trial_division = primes_up_to(limit)
    basic_sieve = sieve_of_eratosthenes(limit)
    seg_sieve = segmented_sieve(limit)

    assert trial_division == basic_sieve == seg_sieve

    # Check a few random numbers
    for n in [2, 17, 101, 997]:
        assert is_prime_naive(n) is True
        assert is_prime_optimized(n) is True
        assert n in trial_division
        assert n in basic_sieve
        assert n in seg_sieve

    for n in [4, 100, 999]:
        assert is_prime_naive(n) is False
        assert is_prime_optimized(n) is False
        assert n not in trial_division
        assert n not in basic_sieve
        assert n not in seg_sieve


@pytest.mark.parametrize(
    "func",
    [
        sieve_of_eratosthenes,
        segmented_sieve,
    ],
)
def test_prime_large_n(func):
    """Test prime generation implementations with larger inputs."""
    # Skip trial division for large n as it would be too slow
    n = 10000
    assert len(func(n)) == 1229  # There are 1229 primes under 10000
