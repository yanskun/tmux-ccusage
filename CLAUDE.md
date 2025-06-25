# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a tmux plugin for displaying CPU core usage in the tmux status bar. The plugin monitors system CPU utilization and provides customizable display options for individual core or aggregate usage statistics.

## Architecture

### Core Components
- **Main Plugin Script** (`ccusage.tmux`): Entry point that integrates with tmux and handles plugin initialization
- **Monitoring Scripts** (`scripts/`): Contains the core CPU monitoring logic and cross-platform compatibility
- **Configuration**: Plugin options for display format, update intervals, and color schemes

### tmux Plugin Integration
- Follows standard tmux plugin conventions for TPM (Tmux Plugin Manager) compatibility
- Integrates with tmux status-right/status-left configuration
- Uses tmux plugin option system for user customization

### Cross-Platform Support
- Targets macOS, Linux, and FreeBSD
- Uses platform-appropriate CPU monitoring tools (`top`, `ps`, `/proc/stat`)
- Handles platform-specific differences in CPU data formatting

## Development Workflow

### Testing
- Test manually with live tmux sessions
- Verify CPU usage accuracy against system monitors
- Test different display formats and update intervals
- Ensure compatibility across target platforms

### Plugin Installation Flow
Users install via TPM with:
```bash
# In .tmux.conf
set -g @plugin 'yanskun/tmux-ccusage'
```

### Configuration Options
Plugin should support tmux options like:
- `@ccusage_update_interval`: Refresh rate in seconds
- `@ccusage_format`: Display format (percentage, bar, icons)
- `@ccusage_show_cores`: Individual cores vs aggregate
- `@ccusage_colors`: Color scheme configuration

## Key Implementation Notes

### CPU Data Collection
- Use efficient system calls to minimize overhead
- Cache data appropriately to avoid excessive system queries
- Handle edge cases like system load spikes or missing data

### tmux Integration
- Register with tmux's interpolation system for status bar display
- Follow tmux plugin naming conventions for options and functions
- Ensure clean plugin initialization and cleanup

### Performance Considerations
- Keep CPU monitoring lightweight to avoid impacting system performance
- Use appropriate update intervals (typically 1-5 seconds)
- Optimize shell script execution for minimal latency