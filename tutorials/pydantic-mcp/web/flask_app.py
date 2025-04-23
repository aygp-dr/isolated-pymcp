"""
Flask web application that integrates with MCP Run Python.
"""
import json
import subprocess
from flask import Flask, request, jsonify, render_template_string
from tempfile import NamedTemporaryFile

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>MCP Run Python</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        textarea { width: 100%; height: 200px; font-family: monospace; }
        .output { white-space: pre-wrap; background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .error { color: red; }
        h1 { color: #333; }
        button { padding: 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        .dependencies { margin-bottom: 10px; }
    </style>
</head>
<body>
    <h1>MCP Run Python Playground</h1>
    <div class="dependencies">
        <label for="dependencies">Dependencies (comma-separated):</label>
        <input type="text" id="dependencies" name="dependencies" placeholder="numpy,pandas">
    </div>
    <textarea id="code" placeholder="Enter your Python code here...">print("Hello from MCP Run Python!")
result = 40 + 2
print(f"The answer is: {result}")
result</textarea>
    <br>
    <button onclick="runCode()">Run Code</button>
    <h2>Output:</h2>
    <div id="output" class="output"></div>

    <script>
        function runCode() {
            const code = document.getElementById('code').value;
            const dependencies = document.getElementById('dependencies').value.split(',').filter(d => d.trim());
            
            fetch('/run', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ code, dependencies })
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('output').innerHTML = `<div class="error">${data.error}</div>`;
                } else {
                    document.getElementById('output').innerText = data.output;
                }
            })
            .catch(error => {
                document.getElementById('output').innerHTML = `<div class="error">Error: ${error}</div>`;
            });
        }
    </script>
</body>
</html>
"""

def run_with_metadata(code, dependencies=None):
    """Run Python code with dependencies."""
    metadata = {}
    if dependencies:
        metadata["dependencies"] = dependencies
    
    with NamedTemporaryFile("w", suffix=".py") as f:
        # Add metadata block if needed
        if metadata:
            f.write("# /// script\n")
            for k, v in metadata.items():
                f.write(f"# {k} = {v!r}\n")
            f.write("# ///\n\n")
        
        # Write the actual code
        f.write(code)
        f.flush()
        
        deno_args = [
            "deno",
            "run",
            "-N",
            "-R=node_modules",
            "-W=node_modules",
            "--node-modules-dir=auto",
            "--allow-read",
            "jsr:@pydantic/mcp-run-python",
            "stdio",
        ]
        
        payload = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "run_python_code",
                "arguments": {
                    "python_code": open(f.name).read()
                }
            },
            "id": 1,
        }
        
        payload_str = json.dumps(payload)
        
        try:
            result = subprocess.run(
                deno_args,
                input=payload_str.encode(),
                capture_output=True,
                check=True,
                timeout=30,  # 30 second timeout for safety
            )
            
            response = json.loads(result.stdout.decode())
            
            if "error" in response:
                return {"error": response["error"]["message"]}
            
            xml_content = response["result"]["content"][0]["text"]
            return {"output": xml_content}
        except subprocess.TimeoutExpired:
            return {"error": "Code execution timed out"}
        except Exception as e:
            return {"error": str(e)}

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/run', methods=['POST'])
def run_code():
    data = request.json
    code = data.get('code', '')
    dependencies = data.get('dependencies', [])
    
    result = run_with_metadata(code, dependencies)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, port=5000)