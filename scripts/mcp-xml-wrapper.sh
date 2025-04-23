#!/usr/bin/env bash
# Simple wrapper that makes MCP Python responses into valid XML

# Python code using a lambda expression
PYTHON_CODE="print(list(map(lambda n: n*n, range(10))))"

# Create the JSON-RPC request with the Python code directly
JSON_REQUEST="{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"run_python_code\", \"arguments\": {\"python_code\": \"$PYTHON_CODE\"}}, \"id\": 1}"

# Execute the request and format the response as XML
echo "$JSON_REQUEST" | \
deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto --allow-read=. \
jsr:@pydantic/mcp-run-python stdio | \
jq -r '.result.content[0].text' | \
/usr/local/bin/gsed '1i<_>' | /usr/local/bin/gsed '$a</_>' | \
xmllint --format -
