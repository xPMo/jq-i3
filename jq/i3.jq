#!/usr/bin/env jq
module {
	"name": "i3"
};

def stack(condition):
	(del(.nodes) | del(.floating_nodes)) as $this |
	if condition then
		[$this], [$this] + ((.nodes + .floating_nodes)[] | stack(condition))
	elif . then
		[$this] + ((.nodes + .floating_nodes)[] | stack(condition))
	else
		empty
	end;	

def stack: stack(.focused);

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
