(defun my-mcp-evaluate-math (expression)
  "Evaluate a mathematical EXPRESSION using MCP Python."
  (interactive "sEnter math expression: ")
  (mcp-run-python-code (format "
import numpy as np
from sympy import symbols, sympify, solve
import math

# Define common symbols
x, y, z = symbols('x y z')

# Evaluate the expression
result = eval('%s')
print(f'Result: {result}')
result
" expression)))

;; Data Analysis Helper
(defun my-mcp-analyze-csv (file)
  "Analyze a CSV file using MCP Python."
  (interactive "fSelect CSV file: ")
  (mcp-run-python-code (format "
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import io
import base64
import json

# Read the CSV file
df = pd.read_csv('%s')

# Basic statistics
stats = df.describe().to_dict()

# Preview of the data
print(f'Data preview:\\n{df.head()}\\n')

# Column info
print(f'Columns: {list(df.columns)}')
print(f'Data types:\\n{df.dtypes}\\n')

# Missing values
print(f'Missing values:\\n{df.isnull().sum()}\\n')

# Create a simple visualization if numeric columns exist
numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
if numeric_cols:
    plt.figure(figsize=(10, 6))
    for col in numeric_cols[:3]:  # Plot up to 3 columns
        plt.plot(df[col], label=col)
    plt.legend()
    plt.title('Numeric Column Trends')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    img_str = base64.b64encode(buf.read()).decode('utf-8')
    plot_data = f'data:image/png;base64,{img_str}'
else:
    plot_data = None

# Return summary data
{
    'rows': len(df),
    'columns': len(df.columns),
    'column_names': list(df.columns),
    'stats': stats,
    'plot': plot_data
}
" file)))
