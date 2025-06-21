extends Node3D

#func _init() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F11:
		get_tree().root.mode = Window.MODE_WINDOWED \
			if get_tree().root.mode == Window.MODE_FULLSCREEN \
			else Window.MODE_FULLSCREEN
