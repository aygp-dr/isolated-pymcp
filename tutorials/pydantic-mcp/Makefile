# Makefile for the Pydantic AI and MCP Run Python Tutorial

.PHONY: setup test examples solutions run-flask all clean

# Default target
all: setup examples solutions

# Setup the environment
setup:
	@echo "Setting up the environment..."
	@bash scripts/setup.sh

# Run the test script
test:
	@echo "Testing MCP Run Python setup..."
	@bash scripts/test_mcp.sh

# Run all examples
examples:
	@echo "Running basic examples..."
	@python examples/mcp_basics.py
	@python examples/run_python.py
	@python examples/run_with_dependencies.py
	@python examples/algorithms_runner.py

# Run exercise solutions
solutions:
	@echo "Running exercise solutions..."
	@python solutions/exercise_solutions.py

# Run the Flask web application
run-flask:
	@echo "Starting Flask web application..."
	@python web/flask_app.py

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	@rm -rf __pycache__
	@rm -rf examples/__pycache__
	@rm -rf solutions/__pycache__
	@rm -rf web/__pycache__