#!/usr/bin/env python3
"""
Claude Code Rule Loader

This script loads and processes Claude Code rules from the .claude/rules directory.
It can be used to validate rules, list available rules, or apply rules to code.
"""

import os
import sys
import yaml
import glob
from pathlib import Path
from typing import Dict, List, Optional


class Rule:
    """Represents a Claude Code rule with metadata and content."""
    
    def __init__(self, path: Path):
        """Load a rule from a markdown file."""
        self.path = path
        self.category = path.parent.name
        self.name = path.stem
        self.metadata = {}
        self.content = ""
        self._parse_file()
    
    def _parse_file(self):
        """Parse the rule file to extract metadata and content."""
        with open(self.path, 'r') as f:
            content = f.read()
        
        # Extract YAML frontmatter
        if content.startswith('---'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                try:
                    self.metadata = yaml.safe_load(parts[1])
                    self.content = parts[2].strip()
                except yaml.YAMLError:
                    print(f"Error parsing YAML frontmatter in {self.path}")
                    self.content = content
            else:
                self.content = content
        else:
            self.content = content
    
    def __str__(self):
        return f"{self.category}/{self.name} ({self.metadata.get('severity', 'unknown')})"


class RuleLoader:
    """Loads and manages Claude Code rules."""
    
    def __init__(self, rules_dir: str = None):
        """Initialize with the rules directory."""
        if rules_dir is None:
            # Default to the directory where this script is located
            script_dir = Path(__file__).parent
            self.rules_dir = script_dir
        else:
            self.rules_dir = Path(rules_dir)
        
        self.rules: Dict[str, Rule] = {}
        self.load_rules()
    
    def load_rules(self):
        """Load all rules from the rules directory."""
        rule_files = glob.glob(str(self.rules_dir / "**" / "*.md"), recursive=True)
        for rule_file in rule_files:
            path = Path(rule_file)
            # Skip README files
            if path.name.lower() == "readme.md":
                continue
            
            rule = Rule(path)
            rule_id = f"{rule.category}/{rule.name}"
            self.rules[rule_id] = rule
    
    def get_rule(self, rule_id: str) -> Optional[Rule]:
        """Get a specific rule by ID."""
        return self.rules.get(rule_id)
    
    def get_rules_by_category(self, category: str) -> List[Rule]:
        """Get all rules in a specific category."""
        return [rule for rule_id, rule in self.rules.items() 
                if rule.category == category]
    
    def get_rules_by_severity(self, severity: str) -> List[Rule]:
        """Get all rules with a specific severity level."""
        return [rule for rule_id, rule in self.rules.items() 
                if rule.metadata.get('severity') == severity]
    
    def list_rules(self):
        """Print a list of all available rules."""
        if not self.rules:
            print("No rules found.")
            return
        
        print(f"Found {len(self.rules)} rules:")
        categories = sorted(set(rule.category for rule in self.rules.values()))
        
        for category in categories:
            print(f"\n{category.upper()}:")
            category_rules = sorted(
                [rule for rule in self.rules.values() if rule.category == category],
                key=lambda r: r.metadata.get('severity', 'unknown')
            )
            
            for rule in category_rules:
                title = rule.metadata.get('title', rule.name)
                severity = rule.metadata.get('severity', 'unknown')
                print(f"  - {title} ({severity})")


def main():
    """Command-line interface for rule loader."""
    loader = RuleLoader()
    
    if len(sys.argv) < 2:
        # Default action: list all rules
        loader.list_rules()
        return
    
    command = sys.argv[1]
    
    if command == "list":
        loader.list_rules()
    
    elif command == "get" and len(sys.argv) > 2:
        rule_id = sys.argv[2]
        rule = loader.get_rule(rule_id)
        if rule:
            print(f"Rule: {rule.metadata.get('title', rule.name)}")
            print(f"Category: {rule.category}")
            print(f"Severity: {rule.metadata.get('severity', 'unknown')}")
            print(f"Language: {rule.metadata.get('language', 'unknown')}")
            print("\nContent:")
            print(rule.content)
        else:
            print(f"Rule '{rule_id}' not found.")
    
    elif command == "category" and len(sys.argv) > 2:
        category = sys.argv[2]
        rules = loader.get_rules_by_category(category)
        if rules:
            print(f"Rules in category '{category}':")
            for rule in sorted(rules, key=lambda r: r.name):
                print(f"  - {rule.metadata.get('title', rule.name)}")
        else:
            print(f"No rules found in category '{category}'.")
    
    else:
        print("Usage:")
        print("  rule-loader.py                  List all rules")
        print("  rule-loader.py list             List all rules")
        print("  rule-loader.py get RULE_ID      Display a specific rule")
        print("  rule-loader.py category NAME    List rules in a category")


if __name__ == "__main__":
    main()