#!/usr/bin/env python3
"""Example of a custom LSP extension."""
import json
import sys
from typing import Dict, Any

class CustomLSPExtension:
    """Custom LSP extension that adds support for a new method."""
    
    def __init__(self, base_server):
        self.base_server = base_server
        self.base_server.handler_map['custom/generateDocumentation'] = self.handle_generate_documentation
    
    def handle_generate_documentation(self, message: Dict[str, Any]):
        """Handle custom/generateDocumentation request."""
        params = message.get('params', {})
        uri = params.get('textDocument', {}).get('uri', '')
        
        # In a real implementation, this would generate documentation
        # for the code in the document
        documentation = "# Generated Documentation\n\n"
        documentation += "This is automatically generated documentation for the code."
        
        response = {
            'documentation': documentation
        }
        
        self.base_server.send_response(message['id'], response)


# Example usage (not executed directly)
def extend_lsp_server():
    """Example of how to use the custom extension."""
    from simple_lsp_server import SimpleLSPServer
    
    server = SimpleLSPServer()
    server.handler_map = {
        'initialize': server.handle_initialize,
        'initialized': server.handle_initialized,
        'shutdown': server.handle_shutdown,
        'exit': server.handle_exit,
        'textDocument/didOpen': server.handle_text_document_did_open,
        'textDocument/didChange': server.handle_text_document_did_change,
        'textDocument/hover': server.handle_text_document_hover,
        'textDocument/completion': server.handle_text_document_completion
    }
    
    # Extend the server with custom functionality
    extension = CustomLSPExtension(server)
    
    # Add the capability to the initialization response
    original_handle_initialize = server.handle_initialize
    def extended_handle_initialize(message):
        response = original_handle_initialize(message)
        response['capabilities']['customDocumentationProvider'] = True
        return response
    
    server.handle_initialize = extended_handle_initialize
    
    return server
