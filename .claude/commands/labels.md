# `/labels` Command

Apply standardized labels to GitHub issues and pull requests.

## Syntax

```
/labels [--add LABEL] [--remove LABEL] [--list] [--help]
```

## Description

The `/labels` command helps maintain consistent labeling in the repository by providing a standardized way to add and remove labels from issues and pull requests. It follows the repository's labeling convention and ensures appropriate labels are applied.

## Label Hierarchy

This repository uses a structured labeling system:

### Primary Category Labels
- `bug` - Something isn't working correctly
- `enhancement` - New features or enhancements to existing functionality
- `documentation` - All documentation-related work
- `security` - Security-related issues and vulnerabilities
- `question` - Requests for information
- `duplicate` - Duplicate issues or PRs
- `wontfix` - Issues that won't be addressed

### Component Labels
Each component label identifies a major architectural component of the system:

- `component: mcp` - Model Context Protocol implementation
- `component: lsp` - Language Server Protocol integration
- `component: algorithms` - Algorithm implementations and analysis
- `component: education` - Tutorials, courses, and learning materials
- `component: container` - Docker/Podman configuration and infrastructure

### Priority Labels
- `priority: high` - Urgent issues requiring immediate attention
- `priority: medium` - Important issues to address soon
- `priority: low` - Issues that can be addressed when time permits

### Expertise Labels
- `expertise: beginner` - Good for new contributors
- `expertise: intermediate` - Requires some familiarity with the codebase
- `expertise: advanced` - Requires deep knowledge of the system

## Label Application Guidelines

1. **Every issue should have at least one primary category label**
2. **Component labels should be used whenever possible** to indicate which part of the system is affected
3. **Don't use redundant labels** (e.g., don't use both `documentation` and `area: docs`)
4. **Priority labels are optional** but recommended for bugs and enhancements
5. **Expertise labels help new contributors** find appropriate issues to work on

## Options

- `--add LABEL` - Add a label to the current issue/PR
- `--remove LABEL` - Remove a label from the current issue/PR
- `--list` - List all available labels in the repository
- `--help` - Display help for this command

## Examples

```
/labels --add enhancement
```
Adds the enhancement label to the current issue/PR.

```
/labels --add component: mcp --add priority: medium
```
Adds both component and priority labels.

```
/labels --remove documentation --add component: education
```
Removes the documentation label and adds the component: education label.

```
/labels --list
```
Lists all available labels in the repository.

## Related Commands

- `/issue` - Create or update GitHub issues
- `/pr` - Create or update pull requests

## See Also

- GitHub's labeling documentation: https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels