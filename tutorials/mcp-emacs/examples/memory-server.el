;; Store a value
(mcp-call-function 'memory "tools/call"
                  '(("name" . "memory_store")
                    ("arguments" . (("key" . "example_key")
                                   ("value" . "example_value")))))

;; Retrieve a value
(mcp-call-function 'memory "tools/call"
                  '(("name" . "memory_retrieve")
                    ("arguments" . (("key" . "example_key")))))
