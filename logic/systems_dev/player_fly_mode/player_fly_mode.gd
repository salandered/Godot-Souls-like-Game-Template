class_name FlyMode
extends Node3DLogger


@export var _player: Princess


const _TRACKING_ANGULAR_SPEED := 4.0

var fly_mode_enabled := false
var fly_speed := 5.0


func get_player() -> Princess:
	return _player


func _process(delta: float) -> void:
	if not fly_mode_enabled:
		return

	if not get_player():
		return
	
	var result_velocity := _handle_free_fly_movement(delta)

	# prevents flipping 180 degrees when just floating Up/Down (Q/E)
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S) or \
	   Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D):
		_rotate_towards_velocity(result_velocity, delta)
	
	get_player().velocity = result_velocity
	get_player().move_and_slide()


func _rotate_towards_velocity(velocity: Vector3, delta: float) -> void:
	if velocity.length_squared() < 0.001:
		return

	var target_direction := Vector3(velocity.x, 0, velocity.z).normalized()
	if target_direction.is_zero_approx():
		return

	var face_direction := get_player().basis.z
	var angle := face_direction.signed_angle_to(target_direction, Vector3.UP)
	
	get_player().rotate_y(clamp(angle, -_TRACKING_ANGULAR_SPEED * delta, _TRACKING_ANGULAR_SPEED * delta))


func _toggle_fly_mode():
	if not get_player():
		__log_warn("No player!")
		return
	fly_mode_enabled = not fly_mode_enabled
	if fly_mode_enabled:
		get_player().velocity = Vector3.ZERO
	__log_("Fly mode:", fly_mode_enabled)


func _handle_free_fly_movement(delta: float) -> Vector3:
	var movement := Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W): movement += Vector3.FORWARD
	if Input.is_key_pressed(KEY_S): movement += Vector3.BACK
	if Input.is_key_pressed(KEY_A): movement += Vector3.LEFT
	if Input.is_key_pressed(KEY_D): movement += Vector3.RIGHT
	if Input.is_key_pressed(KEY_Q): movement += Vector3.DOWN
	if Input.is_key_pressed(KEY_E): movement += Vector3.UP
	
	if movement == Vector3.ZERO:
		return Vector3.ZERO

	var camera := get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO

	var current_speed := fly_speed

	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= 3.0

	return camera.global_transform.basis * movement.normalized() * current_speed


func _input(event: InputEvent) -> void:
	if eu.is_release():
		return

	if Input.is_action_just_pressed(RawAction.DEV_fly_mode):
		_toggle_fly_mode()

	if fly_mode_enabled and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fly_speed *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fly_speed /= 1.1
