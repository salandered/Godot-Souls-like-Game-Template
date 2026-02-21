extends Node


## experimental

func _input(event):
	if u.is_release():
		return
	if event.is_action_pressed(RawAction.DEV_toggle_fullscreen_1):
		_toggle_fullscreen_initial_method(event)
	# if event.is_action_pressed(RawAction.DEV_toggle_fullscreen_2):
		# _toggle_fullscreen_second_method()


func _toggle_fullscreen_initial_method(event: InputEvent) -> void:
	if u.is_release():
		return

	match InputUtils.get_keycode(event):
		KEY_F11:
			get_tree().root.mode = Window.MODE_WINDOWED \
				if get_tree().root.mode == Window.MODE_FULLSCREEN \
				else Window.MODE_FULLSCREEN


func _toggle_fullscreen_second_method():
	if u.is_release():
		return
	if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN \
		and get_window().mode != Window.MODE_FULLSCREEN:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	InputUtils.mark_input_handled(self )
