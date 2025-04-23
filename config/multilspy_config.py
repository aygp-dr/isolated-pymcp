"""
Configuration for MultilspyLSP server

This module provides the configuration settings for the MultilspyLSP server,
which is used to provide language server capabilities for Python code.
"""
import os
from typing import Dict, List, Union

# Server configuration
SERVER_CONFIG: Dict[str, Union[int, str]] = {
    "port": int(os.environ.get("MCP_MULTILSPY_PORT", "3005")),
    "host": "0.0.0.0",
    "log_level": "info",
    "timeout": 30,
}

# Language server configurations
LANGUAGE_SERVERS: Dict[str, Dict[str, Union[List[str], Dict]]] = {
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
ADDITIONAL_SETTINGS: Dict[str, Union[str, int]] = {
    "workspace_root": "/home/mcp",
    "max_workers": 4,
    "timeout_seconds": 30,
}
