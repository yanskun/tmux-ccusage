# tmux-ccusage

A tmux plugin that displays Claude AI usage statistics from [ccusage](https://github.com/ryoppippi/ccusage) in your tmux status bar.

## Prerequisites

- [ccusage](https://github.com/ryoppippi/ccusage) must be installed and available in your PATH
- tmux (tested with tmux 2.0+)

## Installation

### Using TPM (Tmux Plugin Manager) - Recommended

1. Add the following line to your `~/.tmux.conf`:

```bash
set -g @plugin 'yanskun/tmux-ccusage'
```

2. Press `prefix + I` to install the plugin.

3. Add ccusage variables to your status bar:

```bash
# Example: Add to your status-left or status-right
set -g status-right "#{ccusage_today_cost} #{ccusage_today_tokens} | %Y-%m-%d %H:%M"
```

4. Reload tmux configuration:
```bash
tmux source-file ~/.tmux.conf
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yanskun/tmux-ccusage.git ~/.tmux/plugins/tmux-ccusage
   ```

2. Add this line to your `~/.tmux.conf`:
   ```bash
   run-shell ~/.tmux/plugins/tmux-ccusage/ccusage.tmux
   ```

3. Reload tmux configuration:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Usage

After installation, you can use the following interpolation variables in your tmux configuration:

### Available Variables

| Variable | Description | Example Output |
|----------|-------------|----------------|
| `#{ccusage_today_cost}` | Today's total cost | `$0.12` |
| `#{ccusage_yesterday_cost}` | Yesterday's total cost | `$0.06` |
| `#{ccusage_month_cost}` | This month's total cost | `$12.35` |
| `#{ccusage_last_month_cost}` | Last month's total cost | `$45.67` |
| `#{ccusage_today_tokens}` | Today's total tokens | `123K` |
| `#{ccusage_yesterday_tokens}` | Yesterday's total tokens | `89K` |
| `#{ccusage_today_input_tokens}` | Today's input tokens | `67K` |
| `#{ccusage_today_output_tokens}` | Today's output tokens | `56K` |
| `#{ccusage_today_models}` | Models used today | `opus-4 sonnet-4` |
| `#{ccusage_total_cost}` | Total cost (all time) | `$123.46` |
| `#{ccusage_total_tokens}` | Total tokens (all time) | `12M` |
| `#{ccusage_total_input_tokens}` | Total input tokens (all time) | `8M` |
| `#{ccusage_total_output_tokens}` | Total output tokens (all time) | `4M` |

### Example Configuration

Add any of these variables to your tmux status bar:

```bash
# Show today's cost and tokens in status-right
set -g status-right "#{ccusage_today_cost} #{ccusage_today_tokens} | %Y-%m-%d %H:%M"

# Show cost comparison in status-left
set -g status-left "Today: #{ccusage_today_cost} Yesterday: #{ccusage_yesterday_cost} | "

# Show monthly summary
set -g status-right "Month: #{ccusage_month_cost} Today: #{ccusage_today_cost} | %H:%M"

# Show detailed breakdown
set -g status-right "#{ccusage_today_input_tokens}→#{ccusage_today_output_tokens} #{ccusage_today_cost} | #{ccusage_today_models}"

# Show total usage summary
set -g status-right "Total: #{ccusage_total_cost} (#{ccusage_total_tokens}) | Today: #{ccusage_today_cost}"
```

## Token Formatting

- Tokens are automatically formatted with K/M suffixes for readability:
  - `1500` → `1K`
  - `1500000` → `1M`
- Costs are displayed with dollar sign and rounded to 2 decimal places: `$0.12`

## Notes

- The plugin requires `ccusage` to be installed and accessible in your PATH
- Data is fetched in real-time when tmux refreshes the status bar
- If `ccusage` is not available, default values (`$0.00`, `0`, `none`) will be displayed
- The plugin uses basic shell tools for JSON parsing to minimize dependencies

## Example Configuration

For more comprehensive examples, see [.tmux.conf.example](./.tmux.conf.example) which includes various configuration options and color schemes.

## Troubleshooting

1. **No data displayed**: Ensure `ccusage` is installed and working:
   ```bash
   ccusage daily --json
   ```

2. **Permission denied**: Make sure scripts are executable:
   ```bash
   chmod +x ~/.tmux/plugins/tmux-ccusage/scripts/*.sh
   ```

3. **Interpolation not working**: If variables like `#{ccusage_today_cost}` appear literally in your status bar:
   - Make sure the plugin is installed correctly via TPM
   - Try restarting tmux completely: `tmux kill-server && tmux`
   - For manual installation, ensure you have `run-shell ~/.tmux/plugins/tmux-ccusage/ccusage.tmux` in your config

4. **Slow updates**: The plugin fetches data on every status bar refresh. Consider adjusting tmux's `status-interval` if needed.

## License

MIT