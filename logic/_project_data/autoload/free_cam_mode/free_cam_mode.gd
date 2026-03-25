extends Node3DSystem

## Autoload ##

@export var camera_packed_scene: PackedScene
@export var camera_speed := 10.0
@export var mouse_sensitivity := 0.003
@export var pause_on_enter: bool = false
@export var light_on_on_enter: bool = false

@onready var hot_keys: BaseInputDevHotkeys = %HotKeys

var _camera: FreeCamera

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


	set_process(false)
	visible = false


func _process(delta: float) -> void:
	if not is_active or not _enabled:
		return
	move_camera(delta)
	_update_hud()


func _toggle_camera_mode(toggle: bool) -> void:
	if not _enabled:
		return
	__log_("toggling camera mode:", toggle)
	
	is_active = toggle
	set_process(toggle)
	SigUtils.safe_emit_toggle(GlobalSignal.SIG_free_cam_mode_toggled, toggle)
	InputManager.set_input_enabled(not toggle)
	hot_keys.set_enabled(toggle)
	visible = toggle
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
	## going back to main cam
	else:
		get_tree().paused = false
		Input.mouse_mode = _previous_mouse_mode
		if _cached_camera and not _cached_camera.is_queued_for_deletion():
			_cached_camera.current = true
		_turn_off_free_cam()


func _turn_on_free_cam():
	var cam = camera_packed_scene.instantiate()
	if cam is not FreeCamera:
		__log_error("packed scene contains not FreeCamera")
		return
	add_child(cam)

	_camera = cam
	_camera.toggle_light(light_on_on_enter)

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
	if _camera.get_light():
		hud_text += pp.s("\nLight: ", _camera.get_light().visible,
				pp.s(" | Energy: ", _camera.get_light().light_energy))
	hud_text += "\n\n"
	if get_tree().paused:
		hud_text += BB.i_wrap("SCENE PAUSED ⏸️")
	else:
		hud_text += BB.i_wrap("SCENE PLAYS ⏩")

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
		InputUtils.mark_input_handled(self )
		return
	# if event.is_action_pressed(RawAction.UI_escape):
	# 	if is_active:
	# 		_toggle_camera_mode(not is_active)
	# 		InputUtils.mark_input_handled(self )
	# 		return

	if not is_active:
		return

	if event is InputEventMouseMotion:
		_mouse_motion = event.relative


# endregion


## __LOGS
# region

func pp_name():
	return "FreeCam📷"

# endregion
