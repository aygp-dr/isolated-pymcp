#!/usr/bin/env python3
"""
Example: Setting up Claude Code with Anthropic API
"""
import os
import subprocess
from typing import Optional


def setup_claude_code(api_key: Optional[str] = None) -> bool:
    """
    Set up Claude Code with the provided API key.
    
    Args:
        api_key: Anthropic API key. If None, will try to use ANTHROPIC_API_KEY environment variable.
        
    Returns:
        bool: True if setup succeeded, False otherwise.
    """
    # Use environment variable if api_key not provided
    if api_key is None:
        api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not api_key:
            print("Error: No API key provided and ANTHROPIC_API_KEY environment variable not set.")
            return False
    
    # Store API key in configuration
    config_cmd = f"claude config set api_key {api_key}"
    try:
        subprocess.run(config_cmd, shell=True, check=True)
        print("Successfully configured Claude Code with API key.")
        
        # Test configuration
        test_cmd = "claude --version"
        result = subprocess.run(test_cmd, shell=True, capture_output=True, text=True, check=True)
        print(f"Claude Code version: {result.stdout.strip()}")
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error setting up Claude Code: {e}")
        return False


if __name__ == "__main__":
    # Example usage
    setup_claude_code()