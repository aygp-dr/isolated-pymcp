"""
Running Python code with MCP.
"""
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def run_simple_code():
    """Run a simple Python code example."""
    code = """
print("Hello from MCP Run Python!")
result = 40 + 2
print(f"The answer is: {result}")
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
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            print("Running simple Python code...")
            # In MCP client, it's still using the old format but it translates to arguments internally
            result = await session.call_tool('run_python_code', {'python_code': code})
            print("\nResult:")
            print(result.content[0].text)

if __name__ == "__main__":
    import asyncio
    asyncio.run(run_simple_code())