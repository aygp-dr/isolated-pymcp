# FIFO Infrastructure for CONTINUE Framework

## Overview

The CONTINUE framework uses Unix named pipes (FIFOs) for inter-process communication between AI agents. This provides low-latency, synchronous coordination during active development sessions.

## Architecture

```
/tmp/continue/<project>/
├── builder.fifo    # Builder agent channel
├── observer.fifo   # Observer agent channel
├── meta.fifo       # Meta-Observer agent channel
├── announce.fifo   # IRC-style broadcast channel
├── control.fifo    # Control commands (shutdown, etc.)
└── status          # Session status file
```

## Channels

| Channel | Purpose | Access |
|---------|---------|--------|
| `builder` | Builder agent communication | Builder, Meta-Observer |
| `observer` | Observer agent communication | Observer, Meta-Observer |
| `meta` | Meta-Observer communication | Meta-Observer only |
| `announce` | Broadcast announcements (IRC-style) | All agents |
| `control` | Control commands | Meta-Observer only |

## Usage

### Initialize FIFOs

```bash
# Initialize for current project
scripts/continue/fifo-manager.sh init

# Initialize for specific project
scripts/continue/fifo-manager.sh init my-project
```

### Check Status

```bash
scripts/continue/fifo-manager.sh status
```

### Send Messages

```bash
# Send to a specific channel
scripts/continue/fifo-manager.sh send builder "Starting implementation of feature X"

# Broadcast announcement
scripts/continue/fifo-manager.sh announce builder "Completed user authentication module"
```

### Receive Messages (Blocking)

```bash
scripts/continue/fifo-manager.sh recv builder
```

### Cleanup

```bash
scripts/continue/fifo-manager.sh cleanup
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONTINUE_FIFO_BASE` | `/tmp/continue` | Base directory for FIFOs |
| `CONTINUE_PROJECT` | Current directory name | Project namespace |

## Security Considerations

- FIFOs are created with 600 permissions (owner read/write only)
- FIFO directory has 700 permissions (owner access only)
- For sensitive projects, use restricted directories outside `/tmp`
- No at-rest encryption needed (FIFOs are non-persistent)

## Performance

- FIFO message latency: <1ms (local)
- Blocking read until data available or writer connects
- Non-blocking write with 1-second timeout

## Integration with Beads

During a session, agents:
1. Initialize FIFOs at session start
2. Use FIFO channels for real-time coordination
3. Create persistent issues in Beads for discovered work
4. Drain channels and sync to Beads at session end

See `config/continue/agents.yaml` for agent role definitions.
