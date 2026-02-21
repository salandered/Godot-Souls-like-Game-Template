@abstract
@icon("uid://ddu37evdtvh2x")

@tool
class_name BaseInputDevHotkeys
extends NodeLogger


@export var enable_on_init: bool = false


func _ready() -> void:
	if u.is_editor() or u.is_release():
		set_enabled(false)
	else:
		set_enabled(enable_on_init)


func set_enabled(value: bool):
	set_process_input(value)
	set_process_unhandled_input(value)


func _input(event: InputEvent) -> void:
	_input_implementation(event)


func _unhandled_input(event: InputEvent) -> void:
	_unhandled_input_implementation(event)


@abstract func _input_implementation(event: InputEvent) -> void
@abstract func _unhandled_input_implementation(event: InputEvent) -> void


## TEMPLATE

# func _unhandled_input_implementation(event: InputEvent) -> void:
# 	pass

# func _input_implementation(event: InputEvent) -> void:
# 	pass
