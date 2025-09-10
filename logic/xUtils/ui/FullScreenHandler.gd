# extends Node3D

#func _init() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
# var mouse_is_captured: bool = true

# func _input(event: InputEvent) -> void:
# 	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F11:
# 		get_tree().root.mode = Window.MODE_WINDOWED \
# 			if get_tree().root.mode == Window.MODE_FULLSCREEN \
# 			else Window.MODE_FULLSCREEN
	
# 	if event.is_action_released("mouse_mode_switch"):
# 		print("mouse_mode_switch")
# 		if mouse_is_captured:
# 			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
# 		else:
# 			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# 		mouse_is_captured = not mouse_is_captured

# 	if Input.is_action_just_pressed("force_quit"):
# 		get_tree().quit()

extends Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if OS.has_feature("HTML5"):
		if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if event is InputEventKey \
		and event.is_pressed() \
		and (
			event.keycode == KEY_F11 \
			or (
				event.keycode == KEY_ENTER and \
				event.is_alt_pressed()
			)
		):
			get_tree().root.mode = Window.MODE_WINDOWED \
				if get_tree().root.mode == Window.MODE_FULLSCREEN \
				else Window.MODE_FULLSCREEN
