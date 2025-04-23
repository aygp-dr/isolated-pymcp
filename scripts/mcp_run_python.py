#!/usr/bin/env python3
"""
MCP client for executing factorial algorithm through the MCP protocol.

This module provides a simple client for the Model Context Protocol (MCP)
to execute Python code that imports and uses the factorial algorithm.
"""
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

# Python code to execute
code = """
import sys
sys.path.append('.')
from algorithms.factorial import factorial_iterative

result = factorial_iterative(5)
print(f"Factorial of 5 is {result}")
result
"""

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


async def main() -> None:
    """
    Main async function to initialize MCP session and run factorial code.
    
    This function establishes a connection with the MCP server, retrieves
    available tools, and executes Python code that uses the factorial algorithm.
    """
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # List available tools
            tools = await session.list_tools()
            print(f"Found {len(tools.tools)} tools")
            print(f"Tool name: {tools.tools[0].name}")
            print(f"Input schema: {tools.tools[0].inputSchema}")
            
            # Call the run_python_code tool
            print("\nRunning Python code...")
            result = await session.call_tool('run_python_code', {'python_code': code})
            print("\nResult:")
            print(result.content[0].text)


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())