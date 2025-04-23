;; Increase timeout for MCP requests
(setq mcp-default-timeout 60000)  ;; 60 seconds

;; For very long running tasks
(defun my-mcp-run-with-long-timeout (code)
  "Run Python CODE with an extended timeout."
  (interactive "sPython code: ")
  (let ((mcp-default-timeout 120000))  ;; 2 minutes
    (mcp-run-python-code code)))
