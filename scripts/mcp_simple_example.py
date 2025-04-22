#!/usr/bin/env python3
"""
Simple example showing how to use MCP Python runner

This script demonstrates how to set up and use the MCP Python runner client
to execute Python code with dependencies.
"""
import asyncio
from typing import Any, Dict

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

# Example Python code to execute with numpy dependency
code = """
# /// script
# dependencies = ["numpy"]
# ///
import numpy
a = numpy.array([1, 2, 3])
print(a)
a
"""

# Configure server parameters based on the installation command
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

async def main() -> None:
    """
    Main function to execute the MCP Python runner example.

    Connects to the MCP server, initializes a session, lists available tools,
    and runs Python code with the numpy dependency.
    """
    print("Connecting to MCP python-runner...")
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            print("Initializing session...")
            await session.initialize()
            
            print("Listing available tools...")
            tools = await session.list_tools()
            print(f"Found {len(tools.tools)} tools")
            print(f"Tool name: {tools.tools[0].name}")
            
            print("\nRunning Python code with numpy dependency...")
            result = await session.call_tool('run_python_code', {'python_code': code})
            
            print("\nResult:")
            print(result.content[0].text)
            
            if "success" in result.content[0].text:
                print("\n✅ MCP Python runner example successful!")
            else:
                print("\n❌ MCP Python runner example failed!")

if __name__ == "__main__":
    asyncio.run(main())