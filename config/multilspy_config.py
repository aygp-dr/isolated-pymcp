"""
Configuration for MultilspyLSP server
"""
import os
import sys

# Server configuration
SERVER_CONFIG = {
    "port": int(os.environ.get("MCP_MULTILSPY_PORT", 3005)),
    "host": "0.0.0.0",
    "log_level": "info",
    "timeout": 30,
}

# Language server configurations
LANGUAGE_SERVERS = {
    "python": {
        "command": ["pylsp"],
        "settings": {
            "pylsp": {
                "plugins": {
                    "pycodestyle": {
                        "enabled": True,
                        "maxLineLength": 100
                    },
                    "pyflakes": {"enabled": True},
                    "pylint": {"enabled": True},
                    "rope_completion": {"enabled": True},
                    "jedi_completion": {"enabled": True},
                    "jedi_definition": {"enabled": True},
                    "jedi_hover": {"enabled": True},
                    "jedi_references": {"enabled": True},
                    "jedi_signature_help": {"enabled": True},
                    "jedi_symbols": {"enabled": True},
                }
            }
        }
    }
}

# Additional server settings
ADDITIONAL_SETTINGS = {
    "workspace_root": "/home/mcp",
    "max_workers": 4,
    "timeout_seconds": 30,
}
