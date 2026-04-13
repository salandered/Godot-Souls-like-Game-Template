@tool
extends BaseInputDevHotkeys


@export var speed_multiplier := 1.1 # how much each scroll step multiplies speed


func _unhandled_input_implementation(event: InputEvent) -> void:
	pass


func _input_implementation(event: InputEvent) -> void:
	if not FreeCameraMode._enabled:
		return
	if not FreeCameraMode.is_active:
		return

	var camera: FreeCamera = FreeCameraMode._camera
	if not camera:
		return

	_handle_mouse_wheel(event)
	_handle_fov_input(camera, event)
	_handle_light_toggle(camera, event)
	_handle_light_energy_input(camera, event)
	_handle_cinematic_toggle(event)


func _handle_mouse_wheel(event: InputEvent) -> void:
	# Don't change speed if we are changing FOV (RMB is held)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return

	# mouse wheel for speed adjustment
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			FreeCameraMode.camera_speed *= speed_multiplier
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			FreeCameraMode.camera_speed /= speed_multiplier


func _handle_fov_input(camera: FreeCamera, event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	# Hold Right Mouse Button + Scroll to change FOV
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.fov = max(camera.fov - 2, 10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.fov = min(camera.fov + 2, 170)


func _handle_light_energy_input(camera: FreeCamera, event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not camera.get_light():
		return
	
	# Hold LMB + Scroll to change FOV
	# What is this
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.get_light().light_energy = min(camera.get_light().light_energy + 0.2, 10.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.get_light().light_energy = max(camera.get_light().light_energy - 0.2, 0.2)


func _handle_light_toggle(camera: FreeCamera, event: InputEvent) -> void:
	if not camera.get_light():
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		camera.get_light().visible = not camera.get_light().visible
		InputUtils.mark_input_handled(self )


func _handle_cinematic_toggle(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		FreeCameraMode.cinematic_mode = not FreeCameraMode.cinematic_mode
		InputUtils.mark_input_handled(self)