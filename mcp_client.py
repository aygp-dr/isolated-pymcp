from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

code = """
print("Testing simple addition:")
result = 40 + 2
print(f"40 + 2 = {result}")
result
"""

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