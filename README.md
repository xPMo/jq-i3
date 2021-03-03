# jq-i3
A jq module for working with i3 and Sway

## Installation:

Copy or link the file `i3.jq` into your `~/.jq`.

## Usage:

```sh
# Get a flattened list of windows
i3-msg -t get_tree | jq -r 'include "i3"; windows'
# OR
i3-msg -t get_tree | jq -r 'import "i3" as i3; i3::windows'

# Choose a window by name, focus it by id:
i3-msg "[con_id=$(
	i3-msg -t get_tree | jq -r 'include "i3"; windows|.id + "\t" + .name' | fzf --with-nth='2..' | cut -f1
)]" focus

# Get a list of windows matching a certain criteria
i3-msg -t get_tree | jq -r 'include "i3"; windows({"output":"eDP-1"})'

# Debug your bindings:
i3-msg -t subscribe -m '["binding"]' | jq -r 'include "i3"; print_binds' | xargs -n 2 notify-send
```
