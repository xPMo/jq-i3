#!/usr/bin/env jq
module {
	"name": "i3"
};

# Return lists of subtrees array(s) which are parent-child-child...
# where at least one element matches 'condition'.
# If 'found', then also add the list of subtrees resulting from
# recursing on .focus[0]
def stack(condition; found):
	if condition or found then
		if .focus[0] then
			.focus[0] as $target |
			[.] + ((.nodes + .floating_nodes)[] |
				(select(.id == $target) | stack(condition; true )),
				(select(.id != $target) | stack(condition; false))
			)
		else
			[.]
		end
	else
		[.] + ((.nodes + .floating_nodes)[] | stack(condition; found))
	end;

# One arguement: recurse only on 'condition'
def stack(condition): stack(condition; false);

# No arguments: recurse only on .focus[0]
def stack: stack(false; true);

def windows:
	.nodes + .floating_nodes | .[] |
	if .type == "output" then
		{"output": .name} * windows
	elif .type == "workspace" then
		{"workspace": .name} * windows
	elif .nodes | length != 0 then
		windows
	else
		.
	end;

# Usage:
# windows(contains({"name": $ws1, "type": "workspace"}))
def windows(condition):
	.nodes + .floating_nodes | .[] |
	if condition then
		windows
	elif .nodes + .floating_nodes | length != 0 then
		windows(condition)
	else
		empty
	end;

# Usage: i3-msg -t subscribe -m '["binding"]' | ... | xargs -n 2 notify-send
def print_binds:
	select(.change == "run").binding |
	.command , (.event_state_mask + .symbols | join("+"));
