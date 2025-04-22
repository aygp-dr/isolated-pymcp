---
title: Google-style Docstrings
category: documentation
severity: medium
language: python
---

# Google-style Docstrings

## Rule

Use Google-style docstrings for all Python functions, classes, and modules:

1. Include a summary line describing the purpose
2. For functions, document:
   - Args: Parameter descriptions with types
   - Returns: Description of return value with type
   - Raises: Exceptions that may be raised
   - Time/Space complexity for algorithms
3. For classes, document:
   - Attributes
   - Public methods

## Examples

### ✅ Correct

```python
def fibonacci(n: int) -> int:
    """
    Calculate the nth Fibonacci number using dynamic programming.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        n: The position in the Fibonacci sequence (0-indexed)
        
    Returns:
        The nth Fibonacci number
        
    Raises:
        ValueError: If n is negative
    """
    if n < 0:
        raise ValueError("n must be a non-negative integer")
    
    if n <= 1:
        return n
        
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b
```

### ❌ Incorrect

```python
def fibonacci(n):
    # Calculate fibonacci number
    if n < 0:
        raise ValueError("n must be a non-negative integer")
    
    if n <= 1:
        return n
        
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b
```

## Rationale

Good documentation makes code more maintainable, easier to understand, and helps users utilize your code correctly. Google-style docstrings provide a consistent format that is easy to read in both source code and generated documentation.

## References

- [Google Python Style Guide - Docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- [NumPy Style Guide](https://numpydoc.readthedocs.io/en/latest/format.html)