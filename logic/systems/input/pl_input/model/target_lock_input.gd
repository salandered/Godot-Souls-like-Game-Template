class_name TargetLockInput
extends RefCounted


## NOTE: all are mutually exclusive
var tap_waiting: bool = false
var tap: bool = false
var double_tap: bool = false

func no_tap() -> bool:
	return not (tap_waiting or tap or double_tap)

func any_tap() -> bool:
	return tap_waiting or tap or double_tap

func tap_or_double_tap() -> bool:
	return tap or double_tap

func _to_string() -> String:
	return pp.s(" (", tap_waiting, tap, double_tap, ")")
