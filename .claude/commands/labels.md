# `/labels` Command

Apply standardized labels to GitHub issues and pull requests.

## Syntax

```
/labels [--add LABEL] [--remove LABEL] [--list] [--help]
```

## Description

The `/labels` command helps maintain consistent labeling across all issues and pull requests in the repository.

## Options

- `--add LABEL`: Add a label to the issue or PR
- `--remove LABEL`: Remove a label from the issue or PR
- `--list`: List all available labels
- `--help`: Display help information

## Label Categories

The repository uses a structured labeling system:

1. **Primary Category Labels**: `bug`, `enhancement`, `documentation`, `security`, `question`, `duplicate`, `wontfix`
2. **Component Labels**: `component: mcp`, `component: lsp`, `component: algorithms`, `component: education`, `component: container`
3. **Cross-Cutting Concerns**: `testing`, `infrastructure`, `performance`, `refactoring`
4. **Priority Labels**: `priority: high`, `priority: medium`, `priority: low`
5. **Expertise Labels**: `expertise: beginner`, `expertise: intermediate`, `expertise: advanced`

## Examples

```
/labels --add bug
/labels --add component: mcp --add priority: high
/labels --add testing --add performance
/labels --remove documentation --add component: education
/labels --list
```

## Label Application Guidelines

1. Every issue should have at least one primary category label
2. Component labels should be used whenever possible
3. Cross-cutting concern labels can be combined with component labels to add context
4. Don't use redundant labels
5. Priority labels are recommended for bugs and enhancements
6. Expertise labels help new contributors find appropriate issues

For detailed information, see [LABELS.md](../docs/LABELS.md).