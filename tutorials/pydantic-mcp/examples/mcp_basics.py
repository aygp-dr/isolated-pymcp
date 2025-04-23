"""
Basic MCP concepts demonstration.
"""
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def list_tools():
    """List available tools on the MCP Run Python server."""
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
            
            # List available tools
            tools = await session.list_tools()
            print(f"Found {len(tools.tools)} tools")
            
            for tool in tools.tools:
                print(f"\nTool name: {tool.name}")
                print(f"Description: {tool.description.splitlines()[0]}")
                print(f"Input schema: {tool.inputSchema}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(list_tools())