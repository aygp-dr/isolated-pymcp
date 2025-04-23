# Issue Labeling Guide

This document describes the standardized labeling system used in this repository to ensure consistent categorization of issues and pull requests.

## Label Hierarchy

### Primary Category Labels

These labels indicate the general type of the issue:

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working correctly |
| `enhancement` | New features or enhancements to existing functionality |
| `documentation` | All documentation-related work |
| `security` | Security-related issues and vulnerabilities |
| `question` | Requests for information |
| `duplicate` | Duplicate issues or PRs |
| `wontfix` | Issues that won't be addressed |

### Component Labels

Component labels identify which major architectural component of the system is affected:

| Label | Description |
|-------|-------------|
| `component: mcp` | Model Context Protocol implementation |
| `component: lsp` | Language Server Protocol integration |
| `component: algorithms` | Algorithm implementations and analysis |
| `component: education` | Tutorials, courses, and learning materials |
| `component: container` | Docker/Podman configuration and infrastructure |

### Cross-Cutting Concerns

These labels identify issues that span multiple components or represent development aspects rather than specific architectural components:

| Label | Description |
|-------|-------------|
| `testing` | Test coverage, test frameworks, and test methodologies |
| `infrastructure` | CI/CD pipelines, build systems, and development infrastructure |
| `performance` | Performance optimization and benchmarking |
| `refactoring` | Code restructuring without changing functionality |

### Priority Labels

Priority labels help with issue triaging and scheduling:

| Label | Description |
|-------|-------------|
| `priority: high` | Urgent issues requiring immediate attention |
| `priority: medium` | Important issues to address soon |
| `priority: low` | Issues that can be addressed when time permits |

### Expertise Labels

Expertise labels indicate the level of knowledge required to work on an issue:

| Label | Description |
|-------|-------------|
| `expertise: beginner` | Good for new contributors |
| `expertise: intermediate` | Requires some familiarity with the codebase |
| `expertise: advanced` | Requires deep knowledge of the system |

## Label Application Guidelines

1. **Every issue should have at least one primary category label**
2. **Component labels should be used whenever possible** to indicate which part of the system is affected
3. **Cross-cutting concern labels** can be combined with component labels to add context
4. **Don't use redundant labels** (e.g., don't use both `documentation` and `area: docs`)
5. **Priority labels are optional** but recommended for bugs and enhancements
6. **Expertise labels help new contributors** find appropriate issues to work on

## Example Label Combinations

- **Bug in MCP component**: `bug`, `component: mcp`, `priority: high`
- **Documentation Enhancement**: `documentation`, `enhancement`, `expertise: beginner`
- **New Algorithm**: `enhancement`, `component: algorithms`, `expertise: intermediate`
- **Security Fix**: `bug`, `security`, `priority: high`
- **Tutorial Update**: `documentation`, `component: education`, `priority: low`
- **Performance Testing**: `enhancement`, `component: algorithms`, `testing`, `performance`
- **CI Pipeline Fix**: `bug`, `infrastructure`, `priority: medium`
- **Refactoring MCP Code**: `enhancement`, `component: mcp`, `refactoring`