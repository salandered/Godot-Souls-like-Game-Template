extends Node

var mouse_is_captured: bool = true

func _input(event):
	if event.is_action_pressed("dev_toggle_fullscreen_1"):
		_toggle_fullscreen_initial_method(event)
	if event.is_action_pressed("dev_toggle_fullscreen_2"):
		_toggle_fullscreen_second_method()
	if event.is_action_released("mouse_mode_switch"):
		_toggle_mouse_capture()


func _toggle_fullscreen_initial_method(event: InputEvent) -> void:
	if event is InputEventKey \
	and event.is_pressed() \
	and event.keycode == KEY_F11:
		get_tree().root.mode = Window.MODE_WINDOWED \
			if get_tree().root.mode == Window.MODE_FULLSCREEN \
			else Window.MODE_FULLSCREEN


func _toggle_mouse_capture() -> void:
	print("mouse_mode_switch")
	if mouse_is_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_is_captured = not mouse_is_captured

func _toggle_fullscreen_second_method():
	if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN and get_window().mode != Window.MODE_FULLSCREEN:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	get_viewport().set_input_as_handled()
