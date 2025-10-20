extends Node
class_name PlayerMovement

@onready var _player: Princess = $".."
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var animator_manager: AnimatorManager = %AnimatorManager


func get_player() -> Princess:
	return _player

func velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	return _player.model.__velocity_by_input(input_, delta)


## MOVING WITH INPUT VECTOR
# region: code


func process_input_vector(input_: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input_, delta, speed_config)
	_move_with_input_vector(angle, input_, delta, speed_config)
	_player.rotate_y(angle.value)

func move_with_input_vector(input_: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input_, delta, speed_config)
	_move_with_input_vector(angle, input_, delta, speed_config)


func rotate_with_input_vector(input_: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input_, delta, speed_config)
	_player.rotate_y(angle.value)


var _tracking_angular_speed = 10
func rotate_with_input_vector_simple(input_: InputPackage, delta: float):
	var input_direction := velocity_by_input(input_, delta).normalized()
	var face_direction = _player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	_player.rotate_y(clamp(angle, -_tracking_angular_speed * delta, _tracking_angular_speed * delta))


func _move_with_input_vector(angle: AllowedAngle, input_: InputPackage, delta: float, speed_config: SpeedConfig):
	var _speed = speed_config.get_speed()
	var _turn_speed = speed_config.get_turn_speed()
	var _speed_mult = speed_config.get_speed_multiplier()

	var _face_dir = _player.basis.z
	var face_dir_rotated := _face_dir.rotated(Vector3.UP, angle.value)

	if angle.cut:
		_player.velocity = face_dir_rotated * _turn_speed * _speed_mult
	else:
		_player.velocity = face_dir_rotated * _speed * _speed_mult


func _calculate_allowed_angle(input_: InputPackage, delta: float, speed_config: SpeedConfig) -> AllowedAngle:
	var _angular_speed = speed_config.get_angular_sp()

	var input_direction := velocity_by_input(input_, delta).normalized()

	var _face_dir = _player.basis.z
	var angle = _face_dir.signed_angle_to(input_direction, Vector3.UP)

	if abs(angle) >= _angular_speed * delta: # reads as 'max rotation allowed in this frame'
		return AllowedAngle.new(sign(angle) * _angular_speed * delta, true)
	else:
		return AllowedAngle.new(angle)

class AllowedAngle:
	var value: float
	var cut: float

	func _init(_value, _cut: bool = false) -> void:
		value = _value
		cut = _cut

# endregion


## MOVING WITH ROOT
# region: code 

func move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	_player.velocity = _player.get_quaternion() * root_vel


func apply_root_rotation(rot_delta: float, target_angle_: float, accum_rot_: float, check_counter_rot: bool = false) -> Dictionary:
	var remaining_angle = target_angle_ - accum_rot_
	var _log_msg = "rem ∠ " + pp.rad2deg(remaining_angle) + ", rot delta " + pp.rad2deg(rot_delta)

	if check_counter_rot: # do we need this at all if animation s good?
		var is_counter_rotating = (rot_delta < 0 and remaining_angle > 0) or \
								  (rot_delta > 0 and remaining_angle < 0)
		if is_counter_rotating:
			prints(u.fr(), em.pin + "counter rotation, ending turn", _log_msg)
			return {"completed": true, "accum_rot": accum_rot_}

	if abs(rot_delta) >= abs(remaining_angle):
		_player.rotate_y(remaining_angle)
		prints(u.fr(), "Turn complete .", _log_msg)
		return {"completed": true, "accum_rot": target_angle_}
	else:
		_player.rotate_y(rot_delta)
		var new_rotation = accum_rot_ + rot_delta
		# prints(u.fr(), "applied", _log_msg)
		return {"completed": false, "accum_rot": new_rotation}


# endregion


## STRAFE MOVEMENT
# region: code 

func move_forward_or_back(direction_sign: float, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed = speed_config.get_speed()
	var _speed_mult = speed_config.get_speed_multiplier()
	
	# direction_sign: 1.0 for forward, -1.0 for backward
	var forward_vec = _player.basis.z * direction_sign
	_player.velocity = forward_vec * _speed * _speed_mult


func move_strafe_with_forward(input_: InputPackage, direction_sign: float, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed = speed_config.get_speed()
	var _speed_mult = speed_config.get_speed_multiplier()
	
	var forward_vec = - _player.global_basis.z
	var right_vec = _player.global_basis.x
	
	var forward_component = input_.input_direction.y # raw forward/backward input component
	
	# final dir by combining raw f input and the state-controlled strafe direction
	var desired_direction = (forward_vec * forward_component + right_vec * direction_sign)
	
	if desired_direction.is_zero_approx():
		_player.velocity = Vector3.ZERO
		return
	
	var final_velocity = desired_direction.normalized() * _speed * _speed_mult
	_player.velocity = final_velocity


func look_at_target(delta: float, use_model_front: bool = true, speed_config: SpeedConfig = null) -> void:
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _ang_speed = speed_config.get_angular_sp()
	
	if area_awareness.is_camera_locked():
		var target_pos = area_awareness.get_camera_locked_target().global_position
		target_pos.y = _player.global_position.y

		var dir_to_target = _player.global_position.direction_to(target_pos)
		var face_dir = _player.global_basis.z
		
		var remaining_angle = face_dir.signed_angle_to(dir_to_target, Vector3.UP)
		
		var max_rot_this_frame = _ang_speed * delta # maximum rotation allowed in this single frame
		var rotation_this_frame = clampf(remaining_angle, -max_rot_this_frame, max_rot_this_frame)
		
		_player.rotate_y(rotation_this_frame)

# endregion
