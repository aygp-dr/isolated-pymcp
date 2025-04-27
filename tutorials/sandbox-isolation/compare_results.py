#!/usr/bin/env python3
"""
Compare results from direct execution vs. MCP sandbox execution
"""

import json
import os
import sys
from collections import defaultdict

def load_json_file(filename):
    try:
        with open(filename, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        return None

def compare_results():
    results_dir = "results"
    test_types = ["file_access", "command_execution", "network_access", "system_resources"]
    
    # Dictionary to store all results
    comparison = defaultdict(dict)
    
    for test_type in test_types:
        # Load results for direct execution
        direct_filename = f"{results_dir}/{test_type}_results.json"
        if os.path.exists(direct_filename):
            direct_results = load_json_file(direct_filename)
            if direct_results:
                comparison[test_type]["direct"] = direct_results
        
        # Load results for MCP sandbox execution
        mcp_filename = f"{results_dir}/{test_type}_results_mcp.json"
        if os.path.exists(mcp_filename):
            mcp_results = load_json_file(mcp_filename)
            if mcp_results:
                comparison[test_type]["mcp"] = mcp_results
    
    # Generate comparison report
    report = []
    report.append("# Sandbox Isolation Comparison Report")
    report.append("\n## Summary")
    report.append("\nThis report compares the execution of test scripts directly on the host system versus through the MCP sandbox.")
    
    for test_type in test_types:
        report.append(f"\n## {test_type.replace('_', ' ').title()} Tests")
        
        if test_type not in comparison or not comparison[test_type]:
            report.append("\n*No results available for this test type.*")
            continue
        
        direct_results = comparison[test_type].get("direct")
        mcp_results = comparison[test_type].get("mcp")
        
        if not direct_results or not mcp_results:
            if not direct_results:
                report.append("\n*Direct execution results not available.*")
            if not mcp_results:
                report.append("\n*MCP sandbox results not available.*")
            continue
        
        report.append("\n| Test | Direct Execution | MCP Sandbox | Isolation Status |")
        report.append("| ---- | ---------------- | ----------- | ---------------- |")
        
        # Get all unique test keys
        all_tests = set(direct_results.get("tests", {}).keys()) | set(mcp_results.get("tests", {}).keys())
        
        for test_key in sorted(all_tests):
            direct_test = direct_results.get("tests", {}).get(test_key, {})
            mcp_test = mcp_results.get("tests", {}).get(test_key, {})
            
            direct_success = direct_test.get("success", False)
            mcp_success = mcp_test.get("success", False)
            
            direct_status = "✅ Success" if direct_success else "❌ Failed"
            mcp_status = "✅ Success" if mcp_success else "❌ Failed"
            
            # Determine isolation status
            if direct_success and not mcp_success:
                isolation_status = "✅ Properly isolated"
            elif not direct_success and not mcp_success:
                isolation_status = "➖ Both failed"
            elif direct_success and mcp_success:
                # Both succeeded, but might be with different results
                if str(direct_test.get("result")) != str(mcp_test.get("result")):
                    isolation_status = "⚠️ Partial isolation"
                else:
                    isolation_status = "❌ Not isolated"
            else:
                isolation_status = "❓ Unexpected"
            
            test_name = test_key.replace("_", " ").title()
            report.append(f"| {test_name} | {direct_status} | {mcp_status} | {isolation_status} |")
    
    report.append("\n## Conclusion")
    report.append("\nThe above tests demonstrate the security boundaries implemented by the MCP sandbox.")
    report.append("Operations that succeeded in direct execution but failed in the MCP sandbox indicate proper isolation.")
    
    return "\n".join(report)

if __name__ == "__main__":
    report = compare_results()
    
    # Write the report to a Markdown file
    try:
        with open("results/isolation_report.md", "w") as f:
            f.write(report)
        print("Report generated: results/isolation_report.md")
    except Exception as e:
        print(f"Error writing report: {e}")
        print(report)  # Display report in console if file writing fails
