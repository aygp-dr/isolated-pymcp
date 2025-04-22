#!/bin/bash

echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "input": {"python_code": "print(40 + 2)"}}, "id": 2}' | \
deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
--allow-read=. jsr:@pydantic/mcp-run-python stdio