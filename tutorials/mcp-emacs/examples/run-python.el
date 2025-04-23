;; Run Python code string
(mcp-run-python-code "
import numpy as np
x = np.array([1, 2, 3])
print(f'Squared values: {x ** 2}')
x.sum()
")

;; Run Python code from region
;; Select a region and call:
(defun my-run-region-with-mcp ()
  "Run the selected region with MCP Python."
  (interactive)
  (when (use-region-p)
    (mcp-run-python-region (region-beginning) (region-end))))

;; Bind to a key if desired
(global-set-key (kbd "C-c m r") 'my-run-region-with-mcp)
