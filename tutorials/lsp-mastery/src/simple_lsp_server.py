#!/usr/bin/env python3
"""A minimal LSP server implementation."""
import json
import sys
import logging
from typing import Dict, List, Any, Optional, Union

logging.basicConfig(filename='simple_lsp_server.log', level=logging.DEBUG)
logger = logging.getLogger(__name__)

class SimpleLSPServer:
    def __init__(self):
        self.running = True
        self.request_id = 0
        self.documents = {}
        
    def run(self):
        """Main server loop."""
        logger.info("Starting LSP server")
        
        while self.running:
            content_length = 0
            
            # Read headers
            while True:
                header = sys.stdin.readline().strip()
                if not header:
                    break
                if header.startswith('Content-Length:'):
                    content_length = int(header.split(':')[1].strip())
            
            if content_length > 0:
                # Read message content
                content = sys.stdin.read(content_length)
                logger.debug(f"Received message: {content}")
                
                try:
                    message = json.loads(content)
                    self.handle_message(message)
                except json.JSONDecodeError as e:
                    logger.error(f"Error decoding JSON: {e}")
                except Exception as e:
                    logger.error(f"Error handling message: {e}")
    
    def handle_message(self, message: Dict[str, Any]):
        """Process incoming JSON-RPC message."""
        if 'method' in message:
            method = message.get('method', '')
            logger.debug(f"Handling method: {method}")
            
            if method == 'initialize':
                self.handle_initialize(message)
            elif method == 'initialized':
                self.handle_initialized(message)
            elif method == 'shutdown':
                self.handle_shutdown(message)
            elif method == 'exit':
                self.handle_exit(message)
            elif method == 'textDocument/didOpen':
                self.handle_text_document_did_open(message)
            elif method == 'textDocument/didChange':
                self.handle_text_document_did_change(message)
            elif method == 'textDocument/hover':
                self.handle_text_document_hover(message)
            elif method == 'textDocument/completion':
                self.handle_text_document_completion(message)
            else:
                logger.warning(f"Method not implemented: {method}")
                if 'id' in message:
                    self.send_response(message['id'], None)
    
    def handle_initialize(self, message: Dict[str, Any]):
        """Handle initialize request."""
        logger.info("Handling initialize request")
        
        response = {
            'capabilities': {
                'textDocumentSync': {
                    'openClose': True,
                    'change': 2,  # Incremental
                    'willSave': False,
                    'willSaveWaitUntil': False,
                    'save': {
                        'includeText': False
                    }
                },
                'hoverProvider': True,
                'completionProvider': {
                    'triggerCharacters': ['.']
                },
                'definitionProvider': True,
                'referencesProvider': True,
                'documentSymbolProvider': True
            }
        }
        
        self.send_response(message['id'], response)
    
    def handle_initialized(self, message: Dict[str, Any]):
        """Handle initialized notification."""
        logger.info("Handling initialized notification")
        # No response needed for notifications
    
    def handle_shutdown(self, message: Dict[str, Any]):
        """Handle shutdown request."""
        logger.info("Handling shutdown request")
        self.send_response(message['id'], None)
    
    def handle_exit(self, message: Dict[str, Any]):
        """Handle exit notification."""
        logger.info("Handling exit notification")
        self.running = False
        # No response needed for notifications
    
    def handle_text_document_did_open(self, message: Dict[str, Any]):
        """Handle textDocument/didOpen notification."""
        params = message.get('params', {})
        text_document = params.get('textDocument', {})
        uri = text_document.get('uri', '')
        text = text_document.get('text', '')
        
        logger.info(f"Document opened: {uri}")
        self.documents[uri] = text
        
        # Optional: publish diagnostics
        self.publish_diagnostics(uri, [])
    
    def handle_text_document_did_change(self, message: Dict[str, Any]):
        """Handle textDocument/didChange notification."""
        params = message.get('params', {})
        text_document = params.get('textDocument', {})
        uri = text_document.get('uri', '')
        changes = params.get('contentChanges', [])
        
        logger.info(f"Document changed: {uri}")
        
        if uri in self.documents and changes:
            # For simplicity, we just take the full text from the last change
            self.documents[uri] = changes[-1].get('text', self.documents[uri])
            
            # Optional: publish diagnostics
            self.publish_diagnostics(uri, [])
    
    def handle_text_document_hover(self, message: Dict[str, Any]):
        """Handle textDocument/hover request."""
        params = message.get('params', {})
        text_document = params.get('textDocument', {})
        uri = text_document.get('uri', '')
        position = params.get('position', {})
        
        logger.info(f"Hover request: {uri} at position {position}")
        
        response = {
            'contents': {
                'kind': 'markdown',
                'value': '**Simple LSP Server**\n\nThis is a simple hover response.'
            }
        }
        
        self.send_response(message['id'], response)
    
    def handle_text_document_completion(self, message: Dict[str, Any]):
        """Handle textDocument/completion request."""
        params = message.get('params', {})
        text_document = params.get('textDocument', {})
        uri = text_document.get('uri', '')
        position = params.get('position', {})
        
        logger.info(f"Completion request: {uri} at position {position}")
        
        # Very simple completion items
        completion_items = [
            {
                'label': 'function',
                'kind': 1,  # Function
                'detail': 'A function',
                'documentation': 'This is a simple function completion item.'
            },
            {
                'label': 'variable',
                'kind': 6,  # Variable
                'detail': 'A variable',
                'documentation': 'This is a simple variable completion item.'
            },
            {
                'label': 'class',
                'kind': 7,  # Class
                'detail': 'A class',
                'documentation': 'This is a simple class completion item.'
            }
        ]
        
        response = {
            'isIncomplete': False,
            'items': completion_items
        }
        
        self.send_response(message['id'], response)
    
    def publish_diagnostics(self, uri: str, diagnostics: List[Dict[str, Any]]):
        """Send textDocument/publishDiagnostics notification."""
        params = {
            'uri': uri,
            'diagnostics': diagnostics
        }
        
        notification = {
            'jsonrpc': '2.0',
            'method': 'textDocument/publishDiagnostics',
            'params': params
        }
        
        self.send_notification(notification)
    
    def send_response(self, request_id: Union[str, int], result: Any, error: Optional[Dict[str, Any]] = None):
        """Send JSON-RPC response."""
        response = {
            'jsonrpc': '2.0',
            'id': request_id
        }
        
        if error:
            response['error'] = error
        else:
            response['result'] = result
        
        self.send_message(response)
    
    def send_notification(self, notification: Dict[str, Any]):
        """Send JSON-RPC notification."""
        self.send_message(notification)
    
    def send_message(self, message: Dict[str, Any]):
        """Send message to the client."""
        content = json.dumps(message)
        content_length = len(content)
        
        sys.stdout.write(f"Content-Length: {content_length}\r\n\r\n{content}")
        sys.stdout.flush()
        
        logger.debug(f"Sent message: {content}")


if __name__ == "__main__":
    server = SimpleLSPServer()
    server.run()
