# Exercise: Setting Up Claude Code with Anthropic API

## Objective

Configure and test Claude Code with the Anthropic API in a secure way.

## Tasks

1. Create a script to set up Claude Code with environment variables for API keys
2. Implement secure API key storage
3. Add error handling for common setup issues
4. Create a verification function to test that Claude Code is working properly

## Requirements

- Your script should never print the full API key
- Handle the case where the API key environment variable is not set
- Test with both valid and invalid configurations
- Include proper type annotations
- Add clear error messages

## Starting Point

Review the example in `examples/day1/api_setup.py` as a reference, but improve upon it with better security practices.

## Expected Output

When running your script with a valid configuration:

```
Successfully configured Claude Code.
Claude Code is properly configured with API key ending in XXXX.
Claude Code version: 1.2.3
```

When running with an invalid configuration:

```
Error: No API key provided and ANTHROPIC_API_KEY environment variable not set.
Please set the ANTHROPIC_API_KEY environment variable or provide a key.
```

## Bonus Challenge

Add a function that tests the API connection by sending a simple request to Claude and verifying the response.