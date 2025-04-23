# MCP Memory Server Examples

This document provides examples of using the MCP Memory server for stateful operations within an isolated environment.

## What is the Memory Server?

The MCP Memory server provides a simple key-value store that can be used to persist data between calls. This is useful for:

- Storing state between function calls
- Caching computation results
- Passing data between different parts of your application
- Building up complex data structures incrementally

## Basic Key-Value Operations

### Storing a Value

```javascript
// Example using JavaScript client
async function storeValue() {
  const response = await fetch("http://localhost:3002", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "memory_store",
        arguments: {
          key: "user_preferences",
          value: {
            theme: "dark",
            fontSize: 14,
            showLineNumbers: true
          }
        }
      },
      id: 1
    })
  });
  
  return await response.json();
}
```

### Retrieving a Value

```javascript
// Example using JavaScript client
async function retrieveValue() {
  const response = await fetch("http://localhost:3002", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "memory_retrieve",
        arguments: {
          key: "user_preferences"
        }
      },
      id: 2
    })
  });
  
  return await response.json();
}
```

### Deleting a Value

```javascript
// Example using JavaScript client
async function deleteValue() {
  const response = await fetch("http://localhost:3002", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "memory_delete",
        arguments: {
          key: "user_preferences"
        }
      },
      id: 3
    })
  });
  
  return await response.json();
}
```

## Example: Building a Chat History

This example shows how to use the Memory server to build up a chat history:

```python
# Using Python with the run-python MCP server
import json
import requests

# Function to add a message to the chat history
def add_message(role, content):
    # First, retrieve the existing chat history
    response = requests.post(
        "http://localhost:3002",
        json={
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "memory_retrieve",
                "arguments": {
                    "key": "chat_history"
                }
            },
            "id": 1
        }
    )
    
    result = response.json()
    
    # Get the existing chat history or initialize if it doesn't exist
    if "error" in result:
        chat_history = []
    else:
        chat_history = result["result"]["memory_value"]
    
    # Add the new message
    chat_history.append({"role": role, "content": content})
    
    # Store the updated chat history
    response = requests.post(
        "http://localhost:3002",
        json={
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "memory_store",
                "arguments": {
                    "key": "chat_history",
                    "value": chat_history
                }
            },
            "id": 2
        }
    )
    
    return response.json()

# Add some messages
add_message("user", "Hello, how are you?")
add_message("assistant", "I'm doing well, thank you! How can I help you today?")
add_message("user", "I'd like to learn about MCP.")

# Retrieve the full chat history
response = requests.post(
    "http://localhost:3002",
    json={
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "memory_retrieve",
            "arguments": {
                "key": "chat_history"
            }
        },
        "id": 3
    }
)

print(json.dumps(response.json(), indent=2))
```

## Benefits of Using the Memory Server

1. **Stateful Operations**: Maintain state between calls without using a full database
2. **Isolation**: Data is isolated within the MCP environment
3. **Simplicity**: Simple key-value interface is easy to use
4. **Serialization**: Automatically handles JSON serialization/deserialization
5. **Temporary Storage**: Perfect for session-based data that doesn't need permanent storage
