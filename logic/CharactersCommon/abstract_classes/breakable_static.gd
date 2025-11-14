@abstract
class_name BreakableStatic
extends StaticBody3D

## use initialise instead of _ready for heirs

func _ready() -> void:
	initialise()


@abstract func initialise() -> void


@abstract func _is_breakable() -> bool


@abstract func break_myself() -> void
