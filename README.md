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
	i3-msg -t get_tree |
	jq -r 'include "i3"; windows|(.id | tostring) + "\t" + .name' |
	fzf --with-nth='2..' |
	cut -f1
)]" focus

# Get a list of windows matching a certain criteria
i3-msg -t get_tree | jq -r 'include "i3"; windows(contains({"output":"eDP-1"}))'

# (NOTE: these two do the same thing to the full tree, but different things to subtrees)
# Get the list of nodes by following each nodes .focus[0] element
i3-msg -t get_tree | jq -r 'include "i3"; stack'
# Get the list of nodes that are anscestors to the currently focused container
i3-msg -t get_tree | jq -r 'include "i3"; stack(.focused)'

# Get the container id of the closest anscestor which is a tabbed container
i3-msg -t get_tree | jq -r 'include "i3"; [stack[] | select(.layout == "tabbed")] | last.id'

# Do that, but then move to the next tab, then descend until you reach a window
i3-msg -t get_tree | jq -r 'include "i3"; [stack[] | select(.layout == "tabbed")] | last |
	.focus[1] as $nexttab | (.floating_nodes + .nodes)[] |select(.id == $nexttab) | stack[-1].id'


# Debug your bindings:
i3-msg -t subscribe -m '["binding"]' | jq -r 'include "i3"; print_binds' | xargs -n 2 notify-send
```
