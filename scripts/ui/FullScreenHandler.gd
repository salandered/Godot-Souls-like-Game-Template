extends Node3D

#func _init() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F11:
		get_tree().root.mode = Window.MODE_WINDOWED \
			if get_tree().root.mode == Window.MODE_FULLSCREEN \
			else Window.MODE_FULLSCREEN


	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("esc")

	if event is InputEventMouseButton and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("force_quit"):
		get_tree().quit()
