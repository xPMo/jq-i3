#!/usr/bin/env jq
module {
	"name": "i3"
};

# Return all array(s) which are parent-child-child...
# where at least one element matches 'condition'
def stack(condition):
	if condition then
		[.], [.] + ((.nodes + .floating_nodes)[] | stack(condition))
	elif . then
		[.] + ((.nodes + .floating_nodes)[] | stack(condition))
	else
		empty
	end;	

def stack: stack(.focused);

def focus_stack(condition; found):
	if condition or found then
		if .focus[0] then
			.focus[0] as $target |
			[.] + ((.nodes + .floating_nodes)[] |
				(select(.id == $target) | focus_stack(condition; true )),
				(select(.id != $target) | focus_stack(condition; false))
			)
		else
			[.]
		end
	else
		[.] + ((.nodes + .floating_nodes)[] | focus_stack(condition; false))
	end;

def focus_stack(condition): focus_stack(condition; false);

def focus_stack: focus_stack(false; true);

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
