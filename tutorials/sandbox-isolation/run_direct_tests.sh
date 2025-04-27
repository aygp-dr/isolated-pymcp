#!/bin/bash
# Run tests directly on the host system

echo "Running isolation tests directly on the host system..."

# Create results directory
mkdir -p results

# Run each test script
echo "Running file access test..."
python file_access_test.py

echo -e "\nRunning command execution test..."
python command_execution_test.py

echo -e "\nRunning network access test..."
python network_access_test.py

echo -e "\nRunning system resources test..."
python system_resources_test.py

echo -e "\nDirect execution tests completed."
