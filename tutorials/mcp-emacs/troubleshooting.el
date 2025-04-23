;; Check if ports are in use
(defun my-mcp-check-ports ()
  "Check if MCP ports are in use."
  (interactive)
  (shell-command "nc -z localhost 3001 && echo 'Port 3001 in use' || echo 'Port 3001 available'")
  (shell-command "nc -z localhost 3002 && echo 'Port 3002 in use' || echo 'Port 3002 available'")
  (shell-command "nc -z localhost 3003 && echo 'Port 3003 in use' || echo 'Port 3003 available'")
  (shell-command "nc -z localhost 3004 && echo 'Port 3004 in use' || echo 'Port 3004 available'"))

;; Debug MCP server commands
(defun my-mcp-debug-server-commands ()
  "Display commands used to start MCP servers."
  (interactive)
  (message "Run Python: %s" (mapconcat 'identity (alist-get 'run-python mcp-servers-alist) " "))
  (message "Memory: %s" (mapconcat 'identity (alist-get 'memory mcp-servers-alist) " "))
  (message "Filesystem: %s" (mapconcat 'identity (alist-get 'filesystem mcp-servers-alist) " "))
  (message "GitHub: %s" (mapconcat 'identity (alist-get 'github mcp-servers-alist) " ")))
