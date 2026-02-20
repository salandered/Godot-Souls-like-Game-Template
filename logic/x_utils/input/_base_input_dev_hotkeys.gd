@abstract
@icon("uid://ddu37evdtvh2x")

@tool
class_name BaseInputDevHotkeys
extends NodeLogger


func _ready() -> void:
	if u.is_editor() or u.is_release():
		set_process_input(false)
		set_process_unhandled_input(false)
	else:
		set_process_input(true)
		set_process_unhandled_input(true)


func _input(event: InputEvent) -> void:
	_input_implementation(event)


func _unhandled_input(event: InputEvent) -> void:
	_unhandled_input_implementation(event)


@abstract func _input_implementation(event: InputEvent) -> void
@abstract func _unhandled_input_implementation(event: InputEvent) -> void
