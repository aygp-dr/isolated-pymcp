# MCP Tutorials Comparison: pydantic-mcp vs. sandbox-isolation

## Overview

This documentation clearly establishes the separation of concerns between our two MCP tutorials:

1. **pydantic-mcp**: Focuses on **POSITIVE CASES** and **PRACTICAL APPLICATIONS**
2. **sandbox-isolation**: Focuses on **SECURITY TESTING** and **BOUNDARY VALIDATION**

## Detailed Comparison

| Aspect | pydantic-mcp Tutorial | sandbox-isolation Tutorial |
|--------|---------------------|--------------------------|
| **Primary Focus** | Practical use and integration | Security validation and testing |
| **Target Audience** | Developers building applications | Security engineers & system administrators |
| **Use Cases** | Everyday development workflows | Security validation & penetration testing |
| **Content Type** | Instructional & integrative | Analytical & comparative |
| **Technical Depth** | Application-level concepts | System-level security boundaries |

## pydantic-mcp Tutorial: Practical Applications

The **pydantic-mcp** tutorial focuses on POSITIVE use cases and demonstrates how to use the isolated Python environment for everyday development tasks.

### Key Themes

1. **Proper Usage**: How to correctly use the isolated Python environment for development
2. **Practical Examples**: Running algorithms safely within the sandbox
3. **Integration**: Working with existing applications, including a Flask web interface
4. **Best Practices**: Guidelines for working within sandbox constraints
5. **Legitimate Use Cases**: Examples that work well in the sandboxed environment

### Target Audience

- Application developers
- Data scientists
- DevOps engineers integrating MCP into workflows
- AI/ML developers working with Pydantic

### Structure

1. Setting up the Environment (30 min)
2. Understanding MCP Basics (30 min)
3. Running Python Code with MCP (1 hour)
4. Implementing Custom Solutions (1 hour)
5. Integration with Existing Applications (1 hour)

## sandbox-isolation Tutorial: Security Boundaries

The **sandbox-isolation** tutorial focuses on SECURITY TESTING and demonstrates the specific security boundaries of the MCP sandbox through comparative testing.

### Key Themes

1. **Security Boundaries**: Defining the exact limits of the sandbox
2. **Escape Techniques**: Attempted sandbox escapes and how they're blocked
3. **Technical Implementation**: Details of the isolation implementation
4. **Validation Methods**: Systematic testing of security boundaries
5. **Comparative Analysis**: Direct execution vs. sandbox execution results

### Target Audience

- Security engineers
- System administrators
- Security auditors
- Developers concerned with security implications

### Structure

1. File System Access Tests
2. Command Execution Tests
3. Network Access Tests
4. System Resources Tests
5. Comparative Results Analysis

## When to Use Each Tutorial

### Use the pydantic-mcp Tutorial When:

- You want to learn how to integrate MCP into your applications
- You need examples of running algorithms safely
- You're building a web application that uses MCP
- You want to understand the benefits of isolation for regular workflows
- You need practical guidelines for working within constraints

### Use the sandbox-isolation Tutorial When:

- You want to understand the security model in depth
- You need to validate that the sandbox is secure for your use case
- You're concerned about potential security vulnerabilities
- You want to test the effectiveness of the isolation mechanisms
- You need to explain the security boundaries to stakeholders

## Cross-References and Complementary Content

The two tutorials are designed to complement each other, providing a complete picture of the isolated Python environment's capabilities and security model:

- **pydantic-mcp** tutorial references sandbox-isolation when discussing security boundaries
- **sandbox-isolation** tutorial references pydantic-mcp for practical applications of secure execution
- Both use consistent terminology while addressing different aspects
- Security constraints mentioned in pydantic-mcp are fully validated in sandbox-isolation
- Practical applications from pydantic-mcp can be security-validated using sandbox-isolation tests

## Terminology Consistency

To maintain clarity across both tutorials, the following terminology is used consistently:

- **MCP**: Model Context Protocol, the communication mechanism
- **Sandbox**: The isolated execution environment provided by Pyodide
- **Isolation**: The security separation between host and sandbox
- **Pydantic AI**: The framework that includes MCP Run Python

## Conclusion

These two tutorials together provide a comprehensive understanding of the MCP Run Python environment:
1. **pydantic-mcp** shows you *how* to use it productively
2. **sandbox-isolation** explains *why* it's secure

By separating these concerns, we provide a clearer and more focused learning experience for different target audiences while ensuring that all aspects of the system are covered.