# Lint Code

Perform a comprehensive code quality check across the codebase. Focus on:

1. **Code Style**
   - Check for consistent formatting
   - Verify adherence to language-specific style guides
   - Ensure proper indentation and spacing

2. **Code Quality**
   - Identify duplicated code
   - Check for overly complex functions (high cyclomatic complexity)
   - Look for unused variables and imports
   - Find potential memory leaks or resource issues

3. **Best Practices**
   - Verify use of proper error handling
   - Check for appropriate logging
   - Ensure comments and documentation are present
   - Look for hardcoded values that should be configurable

4. **Performance**
   - Identify inefficient algorithms
   - Check for N+1 query problems
   - Look for unnecessary resource usage

5. **Type Safety** (when applicable)
   - Verify proper type annotations
   - Check for potential type errors
   - Review interface implementations

For each issue found:
1. Describe the problem
2. Categorize it (style, quality, safety, etc.)
3. Provide a fix recommendation
4. Include a code example of the fixed version