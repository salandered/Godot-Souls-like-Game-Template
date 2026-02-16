extends Node3DSystem

## Autoload ##

@export var camera_packed_scene: PackedScene
@export var camera_speed := 10.0
@export var mouse_sensitivity := 0.003
@export var speed_multiplier := 1.1 # how much each scroll step multiplies speed
@export var pause_on_enter: bool = true
@export var light_on_on_enter: bool = false


var _camera: FreeCamera
var _light: SpotLight3D

var _cached_camera: Camera3D
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


var _enabled := true
var is_active: bool = false


func __hard_dependencies() -> Array:
	return [
		camera_packed_scene
	]


func _ready() -> void:
	if not __perform_validation():
		__log_warn_soft("not gonna work")
		_enabled = false

	# free cam mode can pause tree, but it itself should still be working
	process_mode = Node.PROCESS_MODE_ALWAYS

	set_process(false)

	hide()


func _process(delta: float) -> void:
	if not is_active or not _enabled:
		return
	
	move_camera(delta)

	_update_hud()


func _toggle_camera_mode(toggle: bool) -> void:
	if not _enabled:
		return
	__log_("~~~ Toggling _camera mode", toggle)
	
	is_active = toggle
	set_process(toggle)
	SigUtils.safe_emit_raw_toggle(GlobalSignal.SIG_free_cam_mode_toggled, toggle)
	InputManager.set_input_enabled(not toggle)
	
	## turn on free cam
	if toggle:
		if pause_on_enter:
			get_tree().paused = true
		_previous_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_cached_camera = get_viewport().get_camera_3d()
		if not _cached_camera:
			__log_warn_soft("can t acquired the cam to return to after toggling free cam mode off")
		_turn_on_free_cam()
		show()
	## going back to main cam
	else:
		get_tree().paused = false
		Input.mouse_mode = _previous_mouse_mode
		if _cached_camera and not _cached_camera.is_queued_for_deletion():
			_cached_camera.current = true
		_turn_off_free_cam()
		hide()


func _turn_on_free_cam():
	var cam = camera_packed_scene.instantiate()
	if cam is not FreeCamera:
		__log_error("packed scene contains not FreeCamera")
		return
	add_child(cam)

	_camera = cam
	_light = _camera.get_light()
	_light.visible = light_on_on_enter


	_camera.current = true
	if _cached_camera:
		_camera.fov = _cached_camera.fov
		_camera.global_transform = _cached_camera.global_transform


func _turn_off_free_cam():
	_camera.queue_free()
	_camera = null


## CAMERA MOVEMENT
# region

var _mouse_motion := Vector2.ZERO

func move_camera(delta: float):
	var movement := _get_keyboard_movement_vector()
	
	# rotation based on mouse movement
	if _mouse_motion != Vector2.ZERO:
		var rotation_input := -_mouse_motion.x * mouse_sensitivity
		var tilt_input := -_mouse_motion.y * mouse_sensitivity
		
		var euler_rotation := _camera.global_transform.basis.get_euler()
		euler_rotation.x += tilt_input
		# limit vertical rotation
		euler_rotation.x = clamp(euler_rotation.x, -PI / 2 + 0.01, PI / 2 - 0.01)
		euler_rotation.y += rotation_input
		_camera.global_transform.basis = Basis.from_euler(euler_rotation)
		
		# reset mouse motion for next frame
		_mouse_motion = Vector2.ZERO
	
	# movement
	_camera.global_position += _camera.global_transform.basis * movement * delta * _get_current_movement_speed()


func _get_current_movement_speed() -> float:
	var current_speed := camera_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= 2.0 # sprint multiplier
	return current_speed

# endregion


## INFO LABELS
# region


func _update_hud() -> void:
	var pos := _camera.global_position
	var rot := _camera.rotation_degrees
	var hud_text := "POS:  %.1f, %.1f, %.1f\nROT:  %.1f, %.1f\nSPD:  %.1f\nFOV:  %.0f" % [
		pos.x, pos.y, pos.z,
		rot.x, rot.y,
		camera_speed,
		_camera.fov
	]

	if _light:
		hud_text += pp.s("\nLight: ", _light.visible, pp.s(" | Energy: ", _light.light_energy))

	if get_tree().paused:
		hud_text += "\n\n[i]SCENE PAUSED ⏸️[/i]"
	else:
		hud_text += "\n\n[i]SCENE PLAYS ⏩[/i]"

	GlobalUIInfo.update_free_cam_hud(hud_text)

# endregion


## INPUT
# region

func _get_keyboard_movement_vector() -> Vector3:
	var movement := Vector3.ZERO
	movement += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	movement += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	movement += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	movement += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	movement += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	movement += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO
	return movement


func _input(event: InputEvent) -> void:
	if not _enabled:
		return
	if event.is_action_pressed(RawAction.DEV_free_cam):
		_toggle_camera_mode(not is_active)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(RawAction.UI_escape):
		if is_active:
			_toggle_camera_mode(not is_active)
			get_viewport().set_input_as_handled()
			return

	if not is_active:
		return

	_handle_pause_toggle(event)
	_handle_mouse_wheel(event)
	if _camera:
		_handle_fov_input(event)
	if _light:
		_handle_light_toggle(event)
		_handle_light_energy_input(event)

	if event is InputEventMouseMotion:
		_mouse_motion = event.relative


func _handle_pause_toggle(event: InputEvent) -> void:
	if InputUtils.is_keycode(event, KEY_P):
		get_tree().paused = not get_tree().paused
		get_viewport().set_input_as_handled()


func _handle_mouse_wheel(event: InputEvent) -> void:
	# Don't change speed if we are changing FOV (RMB is held)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return

	# mouse wheel for speed adjustment
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_speed *= speed_multiplier
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_speed /= speed_multiplier


func _handle_fov_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	# Hold Right Mouse Button + Scroll to change FOV
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera.fov = max(_camera.fov - 2, 10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.fov = min(_camera.fov + 2, 170)


func _handle_light_energy_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	# Hold LMB + Scroll to change FOV
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_light.light_energy = min(_light.light_energy + 0.2, 10.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_light.light_energy = max(_light.light_energy - 0.2, 0.2)


func _handle_light_toggle(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		_light.visible = not _light.visible
		get_viewport().set_input_as_handled()


# endregion


## __LOGS
# region

func pp_name():
	return "FreeCam📷"

# endregion
