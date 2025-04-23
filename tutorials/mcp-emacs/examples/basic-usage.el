;; Start the Python MCP server
(mcp-start-server 'run-python)

;; Run simple Python code
(mcp-run-python-code "
import numpy as np
result = np.array([1, 2, 3]) ** 2
print(f'Result: {result}')
result.sum()
")
