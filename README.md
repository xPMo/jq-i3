# jq-i3
A jq module for working with i3 and Sway

## Installation:

Copy or link the file `i3.jq` into your `~/.jq`.

## Usage:

```sh
# Get a flattened list of windows
i3-msg -t get_tree | jq -r 'include "i3"; windows|.id + "\t" + .name' | fzf --with-nth=2..

# Get a list of windows matching a certain criteria
i3-msg -t get_tree | jq -r 'include "i3"; windows({output:"eDP1"})'

# Debug your bindings:
i3-msg -t subscribe -m '["binding"]' | jq -r 'include "i3"; print_binds' | xargs -n 2 notify-send
```
