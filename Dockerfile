# isolated-pymcp Dockerfile
# Secure, isolated environment for Python development with MCP and LSP

FROM alpine:latest

# Set up non-root user
RUN adduser -D mcp && \
    mkdir -p /home/mcp/data && \
    chown -R mcp:mcp /home/mcp

# Install core dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    npm \
    git \
    curl \
    jq \
    bash \
    deno \
    emacs-nox \
    gcc \
    python3-dev \
    musl-dev

# Switch to non-root user
USER mcp
WORKDIR /home/mcp

# Install uv for Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
ENV PATH="/home/mcp/.cargo/bin:${PATH}"

# Install Python tools via uv
RUN uv pip install --user \
    model-context-protocol \
    python-lsp-server[all] \
    debugpy \
    pytest \
    pytest-cov \
    black \
    isort \
    mypy \
    flake8 \
    multilspy

# Install Claude Code CLI (if available)
RUN npm install -g @anthropic/claude-code || echo "Claude Code CLI not available, skipping"

# Create necessary directories
RUN mkdir -p /home/mcp/algorithms \
             /home/mcp/scripts \
             /home/mcp/data/memory \
             /home/mcp/data/filesystem \
             /home/mcp/data/github \
             /home/mcp/analysis_results

# Copy scripts
COPY --chown=mcp:mcp scripts/ /home/mcp/scripts/
RUN chmod +x /home/mcp/scripts/*.sh

# Copy algorithms
COPY --chown=mcp:mcp algorithms/ /home/mcp/algorithms/

# Environment variables (default values)
ENV MCP_RUNPYTHON_PORT=3001 \
    MCP_MEMORY_PORT=3002 \
    MCP_FILESYSTEM_PORT=3003 \
    MCP_GITHUB_PORT=3004 \
    MCP_MULTILSPY_PORT=3005

# Expose ports for MCP servers
EXPOSE 3001-3010

# Healthcheck
HEALTHCHECK --interval=60s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${MCP_RUNPYTHON_PORT}/health || exit 1

# Entry point
ENTRYPOINT ["/home/mcp/scripts/start-mcp-servers.sh"]
