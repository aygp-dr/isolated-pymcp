#!/bin/bash
# claude-commands-setup.sh
# Create project-specific slash commands for Claude Code

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Claude Code slash commands for static analysis...${NC}"

# Create project commands directory
mkdir -p .claude/commands

# Create code:analyze command
cat > .claude/commands/code:analyze.md << 'EOF'
You are a codebase analysis expert. Your task is to analyze the current repository structure based on the static analysis data in .claude/.cache/repo-context.json.

Please provide a comprehensive analysis including:

1. Overall architecture and code organization
2. Key components and their relationships
3. Code quality assessment
4. Design patterns identified
5. Potential improvements
$ARGUMENTS

Use Mermaid diagrams where appropriate to illustrate your findings.
EOF
echo -e "${GREEN}Created /project:code:analyze command${NC}"

# Create code:diagram command
cat > .claude/commands/code:diagram.md << 'EOF'
Create a detailed Mermaid diagram for the $ARGUMENTS aspect of this codebase.

Use the static analysis data in .claude/.cache/diagrams/ as a reference.

The diagram should:
1. Show the key components and their relationships
2. Use appropriate Mermaid syntax based on diagram type
3. Include meaningful labels and annotations
4. Be organized to maximize readability

Supported diagram types: architecture, data-flow, control-flow, model, component, sequence
EOF
echo -e "${GREEN}Created /project:code:diagram command${NC}"

# Create code:hotspots command
cat > .claude/commands/code:hotspots.md << 'EOF'
Analyze the code hotspots identified in .claude/.cache/analysis/hotspots.json and provide:

1. A detailed explanation of each hotspot
2. The root causes of complexity or issues
3. Specific refactoring suggestions with code examples
4. Implementation priorities based on impact
$ARGUMENTS

Reference the complete context in .claude/.cache/repo-context.json for additional insights.
EOF
echo -e "${GREEN}Created /project:code:hotspots command${NC}"

# Create code:review command
cat > .claude/commands/code:review.md << 'EOF'
Review the code changes in the $ARGUMENTS files/directories and provide:

1. Quality assessment of the changes
2. Potential issues or bugs
3. Suggestions for improvement
4. Security considerations
5. Performance implications

Use the static analysis context in .claude/.cache/repo-context.json to understand the broader codebase.
EOF
echo -e "${GREEN}Created /project:code:review command${NC}"

# Create code:doc command
cat > .claude/commands/code:doc.md << 'EOF'
Generate comprehensive documentation for the $ARGUMENTS component or feature.

Use the static analysis data in .claude/.cache/repo-context.json to:
1. Describe the purpose and functionality
2. Explain key interfaces and data structures
3. Provide usage examples
4. Document integration points with other components
5. Include diagrams where appropriate

Format the documentation in markdown suitable for inclusion in the project wiki or README.
EOF
echo -e "${GREEN}Created /project:code:doc command${NC}"

# Create code:security command
cat > .claude/commands/code:security.md << 'EOF'
Perform a security analysis of the $ARGUMENTS component based on the static analysis data.

Your analysis should include:
1. Identification of potential security vulnerabilities
2. Assessment of input validation and sanitization
3. Review of authentication and authorization mechanisms
4. Evaluation of data protection measures
5. Specific recommendations for security improvements

Reference OWASP guidelines and security best practices in your assessment.
EOF
echo -e "${GREEN}Created /project:code:security command${NC}"

# Create code:visualize command
cat > .claude/commands/code:visualize.md << 'EOF'
Create a visual representation of the $ARGUMENTS using the most appropriate format.

Options include:
- Architecture diagram (system structure)
- Component diagram (modular organization)
- Sequence diagram (process flows)
- Entity-relationship diagram (data models)
- State diagram (state transitions)

Use the context in .claude/.cache/repo-context.json and the diagrams in .claude/.cache/diagrams/ as reference.
EOF
echo -e "${GREEN}Created /project:code:visualize command${NC}"

# Create code:optimize command
cat > .claude/commands/code:optimize.md << 'EOF'
Analyze the $ARGUMENTS component for optimization opportunities based on the static analysis data.

Your response should include:
1. Performance bottlenecks identified
2. Resource utilization issues
3. Algorithmic inefficiencies
4. Specific optimization recommendations with code examples
5. Expected impact of the proposed changes

Reference the hotspots in .claude/.cache/analysis/hotspots.json for areas that may need attention.
EOF
echo -e "${GREEN}Created /project:code:optimize command${NC}"

# Create code:test command
cat > .claude/commands/code:test.md << 'EOF'
Generate comprehensive test cases for the $ARGUMENTS component or feature.

Your response should include:
1. Unit test examples with appropriate assertions
2. Integration test scenarios
3. Edge cases and boundary testing
4. Mock/stub requirements
5. Test organization and structure recommendations

Use the static analysis in .claude/.cache/repo-context.json to understand dependencies and behavior.
EOF
echo -e "${GREEN}Created /project:code:test command${NC}"

# Create a helper symlink for quick access
if [ ! -e "claude-commands" ]; then
  ln -s .claude/commands claude-commands
  echo -e "${GREEN}Created symlink 'claude-commands' for easy access${NC}"
fi

echo -e "${BLUE}Claude Code slash commands setup complete!${NC}"
echo -e "You can now use the following commands in Claude Code:"
echo -e "  /project:code:analyze"
echo -e "  /project:code:diagram <type>"
echo -e "  /project:code:hotspots"
echo -e "  /project:code:review <files>"
echo -e "  /project:code:doc <component>"
echo -e "  /project:code:security <component>"
echo -e "  /project:code:visualize <item>"
echo -e "  /project:code:optimize <component>"
echo -e "  /project:code:test <component>"
echo -e "\nTo edit commands, navigate to .claude/commands/ directory"
