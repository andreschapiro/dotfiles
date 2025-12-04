# Tmux Keybindings & Commands

## Prefix Key
The prefix key is `Ctrl-b` (default)

## Session Management

### Creating & Attaching
- `tmux` - Start a new session
- `tmux new -s name` - Create a named session
- `tmux ls` - List all sessions
- `tmux attach` or `tmux a` - Attach to last session
- `tmux attach -t name` - Attach to specific session

### Inside Tmux
- `Ctrl-b` + `s` - Interactive session list (switch sessions)
- `Ctrl-b` + `d` - Detach from session

## Window Management

- `Ctrl-b` + `c` - Create new window
- `Ctrl-b` + `n` - Next window
- `Ctrl-b` + `p` - Previous window
- `Ctrl-b` + `0-9` - Switch to window number
- `Ctrl-b` + `w` - Interactive window list
- `Ctrl-b` + `,` - Rename current window
- `Ctrl-b` + `&` - Kill current window (with confirmation)

## Pane Management

### Creating Panes
- `Ctrl-b` + `|` - Split vertically (new pane to the right)
- `Ctrl-b` + `-` - Split horizontally (new pane below)

### Navigating Panes (vim-tmux-navigator)
- `Ctrl-h` - Move to left pane
- `Ctrl-j` - Move to pane below
- `Ctrl-k` - Move to pane above
- `Ctrl-l` - Move to right pane

(These work seamlessly between nvim splits and tmux panes!)

### Resizing Panes
- **Mouse**: Click and drag pane borders
- **Keyboard**: 
  - `Ctrl-b` + `Ctrl-←` - Make pane narrower
  - `Ctrl-b` + `Ctrl-→` - Make pane wider
  - `Ctrl-b` + `Ctrl-↑` - Make pane taller
  - `Ctrl-b` + `Ctrl-↓` - Make pane shorter

### Closing Panes
- `exit` or `Ctrl-d` - Exit shell (closes pane)
- `Ctrl-b` + `x` - Kill pane (with confirmation)

## Other Useful Commands

- `Ctrl-b` + `r` - Reload tmux configuration
- `Ctrl-b` + `?` - Show all keybindings
- `Ctrl-b` + `:` - Enter command mode

## Configuration

Configuration file: `~/.config/tmux/tmux.conf`

### Features Enabled
- Mouse support
- Windows/panes start at index 1
- Auto-renumber windows
- True color support
- vim-tmux-navigator plugin for seamless vim/tmux navigation

### Plugins (via TPM)
- `tmux-plugins/tpm` - Tmux Plugin Manager
- `tmux-plugins/tmux-sensible` - Sensible defaults
- `christoomey/vim-tmux-navigator` - Vim integration
