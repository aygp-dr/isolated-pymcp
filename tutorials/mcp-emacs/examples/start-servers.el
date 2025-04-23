;; Start individual servers
(mcp-start-server 'run-python)  ; Python execution
(mcp-start-server 'memory)      ; Memory store
(mcp-start-server 'filesystem)  ; Filesystem operations
(mcp-start-server 'github)      ; GitHub operations

;; Or start all servers at once
(mcp-start-all-servers)
