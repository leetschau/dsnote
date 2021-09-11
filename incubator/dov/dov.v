module main

import os

const (
	usage = 'Usage:
	s: search
	l: List'
)

fn main() {
	if os.args.len <= 1 {
		println(usage)
		exit(1)
	}
	match os.args[1] {
		's' { println('Search ${os.args[2..]} in notes') }
		else { println(usage) }
	}
}
