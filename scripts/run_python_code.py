#!/usr/bin/env python3
"""
Simple utility to execute Python code via MCP Python runner
"""
import asyncio
import sys
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

# Get code from command line arguments
if len(sys.argv) < 2:
    print("Usage: run_python_code.py <python_code>")
    sys.exit(1)

# Join all arguments as the code to run
code = " ".join(sys.argv[1:])

# Configure server parameters
server_params = StdioServerParameters(
    command='deno',
    args=[
        'run',
        '-N',
        '-R=node_modules',
        '-W=node_modules',
        '--node-modules-dir=auto',
        'jsr:@pydantic/mcp-run-python',
        'stdio',
    ],
)

async def main():
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # Run the code
            result = await session.call_tool('run_python_code', {'python_code': code})
            
            # Extract and print the result
            response_text = result.content[0].text
            
            # Parse the response to get just the return value
            if "<return_value>" in response_text and "</return_value>" in response_text:
                start = response_text.find("<return_value>") + len("<return_value>")
                end = response_text.find("</return_value>")
                return_value = response_text[start:end].strip()
                print(return_value)
            else:
                print(response_text)

if __name__ == "__main__":
    asyncio.run(main())