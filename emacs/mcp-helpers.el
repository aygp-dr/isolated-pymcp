;;; mcp-helpers.el --- MCP integration helpers

;;; Code:
(require 'mcp)

(defun mcp-connect-servers ()
  "Connect to MCP servers from environment variables."
  (interactive)
  (mcp-add-server "run-python" (getenv "MCP_RUNPYTHON_URL"))
  (mcp-add-server "multilspy" (getenv "MCP_MULTILSPY_URL"))
  (message "Connected to MCP servers"))

(defun mcp-run-buffer ()
  "Run current buffer with MCP run-python."
  (interactive)
  (let ((code (buffer-substring-no-properties (point-min) (point-max))))
    (mcp-execute "run-python" "run" 
                 `(("code" . ,code))
                 #'mcp-display-result)))

(defun mcp-analyze-buffer ()
  "Analyze current buffer with MultilspyLSP."
  (interactive)
  (let ((code (buffer-substring-no-properties (point-min) (point-max))))
    (mcp-execute "multilspy" "analyze"
                 `(("code" . ,code)
                   ("language" . "python"))
                 #'mcp-display-result)))

(defun mcp-display-result (result)
  "Display RESULT in buffer."
  (with-current-buffer (get-buffer-create "*MCP Result*")
    (erase-buffer)
    (insert result)
    (pop-to-buffer (current-buffer))))

(provide 'mcp-helpers)
;;; mcp-helpers.el ends here
