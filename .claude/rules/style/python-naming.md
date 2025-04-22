---
title: Python Naming Conventions
category: style
severity: medium
language: python
---

# Python Naming Conventions

## Rule

Use consistent naming conventions for Python code:

- Variables and function names: `snake_case`
- Class names: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private attributes: `_leading_underscore`
- Module-level "private" functions: `_leading_underscore`

## Examples

### ✅ Correct

```python
def calculate_total(item_prices):
    TAX_RATE = 0.08
    return sum(item_prices) * (1 + TAX_RATE)

class ShoppingCart:
    def __init__(self):
        self._items = []
    
    def add_item(self, item):
        self._items.append(item)
```

### ❌ Incorrect

```python
def CalculateTotal(itemPrices):
    taxRate = 0.08
    return sum(itemPrices) * (1 + taxRate)

class shopping_cart:
    def __init__(self):
        self.ITEMS = []
    
    def AddItem(self, item):
        self.ITEMS.append(item)
```

## Rationale

Consistent naming conventions improve code readability and maintainability. The Python community has established PEP 8 as the standard style guide, which recommends these naming conventions.

## References

- [PEP 8 - Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/#naming-conventions)
- [Google Python Style Guide - Naming](https://google.github.io/styleguide/pyguide.html#s3.16-naming)