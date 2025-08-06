package Time

import time "core:time"

Tick 	    :: time.Tick
tick_now    :: time.tick_now
tick_diff   :: time.tick_diff
tick_since  :: time.tick_since


@(private="file") start : Tick


_start :: proc "contextless" () { start =  tick_now() }

_get_tick_ms :: proc "contextless" () -> Int {
	return Int(tick_since(start))/1e6
}

_get_tick_ns :: proc "contextless" () -> Int {
	return Int(tick_since(start))
}