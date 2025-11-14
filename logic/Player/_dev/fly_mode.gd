extends Node3D
class_name FlyMode
@onready var _player: Princess = $"../.."


var fly_mode_enabled := false
var fly_speed := 5
var vel_y := 0.0

func get_player() -> Princess:
	return _player


func _process(delta) -> void:
	if not fly_mode_enabled:
		return
	var input_ := InputManager.get_current_input()
	var result_velocity = _handle_fly_mode(input_, delta)
	vel_y = lerp(vel_y, 0.0, 0.3)
	result_velocity = Vector3(result_velocity.x, vel_y, result_velocity.z)
	get_player().velocity = result_velocity
	get_player().move_and_slide()


func _handle_fly_mode(input_: InputPackage, delta: float) -> Vector3:
	var _tracking_angular_speed := 4
	var input_direction := _fly_velocity_by_input(input_, delta).normalized()
	var face_direction := get_player().basis.z
	var angle := face_direction.signed_angle_to(input_direction, Vector3.UP)
	get_player().rotate_y(clamp(angle, -_tracking_angular_speed * delta, _tracking_angular_speed * delta))

	# Normalize and scale
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized() * fly_speed

	return input_direction


func _fly_velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input_.forward_input

	var orbit_speed := input_.orbit_input

	var grounded_target: Vector3
	grounded_target = get_player().fancy_camera.nest.global_position
	grounded_target.y = get_player().global_position.y

	if forward_speed != 0.0:
		_velocity -= get_player().global_position.direction_to(grounded_target) \
					 * forward_speed * 5

	if orbit_speed != 0.0:
		var d: float = orbit_speed * 5 * delta
		var target_direction := grounded_target - get_player().global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - get_player().global_position
		_velocity += d_vector / delta
	return _velocity


func _toggle_fly_mode():
	fly_mode_enabled = !fly_mode_enabled
	if fly_mode_enabled:
		get_player().velocity = Vector3.ZERO
	print_.dev("*** Fly mode: ", fly_mode_enabled)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(RawAction.DEV_fly_mode):
		_toggle_fly_mode()

	if event.is_action_released(RawAction.DEV_speed_up):
		fly_speed += 5
	if event.is_action_released(RawAction.DEV_speed_down):
		fly_speed -= 5

	if Input.is_key_pressed(KEY_Q):
		vel_y = +8
	if Input.is_key_pressed(KEY_E):
		vel_y = -8
