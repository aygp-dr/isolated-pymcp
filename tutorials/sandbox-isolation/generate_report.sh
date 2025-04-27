#!/bin/bash
# Generate the comparison report

echo "Generating comparison report..."

# Run the comparison script
python compare_results.py

echo "Report generation completed."
echo "View the report at: results/isolation_report.md"
