extends Node
class_name PlayerMovement

@onready var _player: Princess = $".."
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var animator_manager: PlAnimatorManager = %AnimatorManager


## DOCS
# region
# - what we call 'move' is officially called 'translate' i suppose
#   'move' might be seen to abstract but it is used in Blender3D (G key)
# - 'rotate' for rotating player.
# endregion


## GETTERS
# region

func get_player() -> Princess:
	return _player

func velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	return __velocity_by_input(input_, delta)


func safe_is_on_floor() -> bool:
	return _player.is_on_floor() or area_awareness.floor_dist_under_tolerated_height()


func almost_on_floor() -> bool:
	return not _player.is_on_floor() and area_awareness.floor_dist_under_tolerated_height()


func get_curr_velocity_len() -> float:
	return _player.velocity.length()

func get_curr_xz_velocity_len() -> float:
	return Vector3(_player.velocity.x, 0, _player.velocity.z).length()

func get_curr_y_velocity() -> float:
	return _player.velocity.y


func get_signed_angle_pl_input(input_, delta, __log) -> float:
	var angle := __angle_between_player_and_input(input_, delta, __log)
	return angle

func get_abs_angle_pl_input(input_, delta) -> float:
	var angle := __angle_between_player_and_input(input_, delta)
	return abs(angle)


func detect_dir_relative_to_facing(input_: InputPackage, delta: float) -> Direction.Dir:
	if abs(input_.forward_input) < 0.01 and abs(input_.orbit_input) < 0.01:
		return Direction.Dir.NEUTRAL
	
	var angle_rad := __angle_between_player_and_input(input_, delta)
	var angle_deg := rad_to_deg(angle_rad)
	
	return _angle_to_direction(angle_deg)


func _angle_to_direction(angle_deg: float) -> Direction.Dir:
	# Normalize angle to -180 to 180 range
	angle_deg = wrapf(angle_deg, -180.0, 180.0)
	
	angle_deg = - angle_deg
	# 8-directional mapping (45° sectors)
	if angle_deg >= -22.5 and angle_deg < 22.5:
		return Direction.Dir.FORWARD
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		return Direction.Dir.RIGHT_F
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		return Direction.Dir.RIGHT
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		return Direction.Dir.RIGHT_B
	elif angle_deg >= 157.5 or angle_deg < -157.5:
		return Direction.Dir.BACKWARD
	elif angle_deg >= -157.5 and angle_deg < -112.5:
		return Direction.Dir.LEFT_B
	elif angle_deg >= -112.5 and angle_deg < -67.5:
		return Direction.Dir.LEFT
	else: # -67.5 to -22.5
		return Direction.Dir.LEFT_F


## returns 0.0 if no target
func get_signed_angle_pl_target() -> float:
	if area_awareness.is_camera_locked():
		var target_pos := area_awareness.get_camera_locked_target().global_position
		target_pos.y = _player.global_position.y

		var dir_to_target := _player.global_position.direction_to(target_pos)
		var _face_dir := _player.global_basis.z
		
		var angle := _face_dir.signed_angle_to(dir_to_target, Vector3.UP)
		return angle
	return 0.0

# endregion

## BASIC MOVING
# region

func set_velocity(velocity: Vector3):
	_player.velocity = velocity


## gravity is expected to be positive value.
## if no gravity, default will be used
func apply_gravity(delta, gravity: float = u.gravity):
	_player.velocity.y -= gravity * delta


func apply_friction_xz(delta: float, friction_value: float = 5.0):
	var new_velocity := _player.velocity
	new_velocity.x = move_toward(new_velocity.x, 0.0, friction_value * delta)
	new_velocity.z = move_toward(new_velocity.z, 0.0, friction_value * delta)
	_player.velocity = new_velocity


func apply_friction(delta: float, friction_value: float = 5.0):
	var horizontal_vel := Vector3(_player.velocity.x, 0, _player.velocity.z)
	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, friction_value * delta)
	
	var new_velocity := _player.velocity
	new_velocity.x = horizontal_vel.x
	new_velocity.z = horizontal_vel.z
	_player.velocity = new_velocity

# endregion


## MOVING WITH INPUT VECTOR
# region


func move_rotate_with_input_vector(input_: InputPackage, delta: float, speed_config: SpeedConfig = null):
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


func _move_with_input_vector(angle: AllowedAngle, input_: InputPackage, delta: float, speed_config: SpeedConfig):
	var _speed := speed_config.get_speed()
	var _turn_speed := speed_config.get_turn_speed()
	var _speed_mult := speed_config.get_speed_multiplier()

	var _face_dir := _player.basis.z
	var face_dir_rotated := _face_dir.rotated(Vector3.UP, angle.value)

	if angle.cut:
		_player.velocity = face_dir_rotated * _turn_speed * _speed_mult
	else:
		_player.velocity = face_dir_rotated * _speed * _speed_mult


func _calculate_allowed_angle(input_: InputPackage, delta: float, speed_config: SpeedConfig) -> AllowedAngle:
	var _angular_speed := speed_config.get_angular_sp()

	var input_direction := velocity_by_input(input_, delta).normalized()

	var _face_dir := _player.basis.z
	var angle := _face_dir.signed_angle_to(input_direction, Vector3.UP)

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


var _DELTA_VECTOR_LENGTH: float = 0.30
## some peculiar version which divides velocity and look direction
func process_input_vector_air(input_: InputPackage, delta: float, jump_direction: Vector3):
	var _input_direction := velocity_by_input(input_, delta).normalized()
	var _input_delta_vector := _input_direction * _DELTA_VECTOR_LENGTH
	
	# ep 6: (jump_direction + input_delta_vector * delta).limit_length(clamp(_player.velocity.length(), 1, 999999))
	jump_direction = (jump_direction + _input_delta_vector).limit_length(_player.velocity.length())
	# u.safe_look_at(_player, _player.global_position - jump_direction)

	# ep 6: (player.velocity + input_delta_vector * delta).limit_length(_player.velocity.length())
	var new_velocity := (_player.velocity + _input_delta_vector).limit_length(_player.velocity.length())
	_player.velocity = new_velocity

# endregion


## MOVING WITH ROOT
# region 


## applies a local-space velocity (e.g., from root motion) to the player
func apply_local_velocity_as_global(local_velocity: Vector3):
	_player.velocity = _player.get_quaternion() * local_velocity


## by default only Y is muted.
## use_blending is not tested
func move_with_root(delta: float, extra_vel: Vector3 = Vector3.ZERO, y_zeroed: bool = true, x_zeroed: bool = false, z_zeroed: bool = false, use_blending: bool = false) -> void:
	# animator already handles the 'y_zeroed' part
	var root_vel := animator_manager.get_root_velocity(y_zeroed, use_blending)
	
	if x_zeroed:
		root_vel.x = 0.0
	if z_zeroed:
		root_vel.z = 0.0
	
	var final_local_vel := root_vel + extra_vel
	apply_local_velocity_as_global(final_local_vel)


func apply_root_rotation(rot_delta: float, target_angle_: float, accum_rot_: float, check_counter_rot: bool = false) -> Dictionary:
	var remaining_angle := target_angle_ - accum_rot_
	var _log_msg: String = "rem ∠ " + pp.rad2deg(remaining_angle) + ", rot delta " + pp.rad2deg(rot_delta)

	if check_counter_rot: # do we need this at all if animation is good?
		var is_counter_rotating := (rot_delta < 0 and remaining_angle > 0) or \
								  (rot_delta > 0 and remaining_angle < 0)
		if is_counter_rotating:
			print_.dev("", em.pin + "counter rotation, ending turn " + _log_msg)
			return {"completed": true, "accum_rot": accum_rot_}

	if abs(rot_delta) >= abs(remaining_angle):
		_player.rotate_y(remaining_angle)
		print_.dev("", "Turn complete. " + _log_msg)
		return {"completed": true, "accum_rot": target_angle_}
	else:
		_player.rotate_y(rot_delta)
		var new_rotation := accum_rot_ + rot_delta
		# prints(u.fr(), "applied", _log_msg)
		return {"completed": false, "accum_rot": new_rotation}


## Z means forward
func calculate_extra_root_speed_Z(anim: AnimationData, _start_time_offset: float, extra_speed_z: float, __log: bool = false) -> float:
	var _inherited_speed := get_curr_velocity_len()
	var root_start_speed := animator_manager.calculate_animation_start_root_velocity(anim, _start_time_offset, true)
	var _r = max(0.0, _inherited_speed - root_start_speed + extra_speed_z)
	if __log: __log_("inheritedSp", _inherited_speed, " rootStartSp", root_start_speed, " extraSp Z", _r)
	return _r

# endregion


## STRAFE MOVEMENT
# region 

func move_forward_or_back(direction_sign: float, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed := speed_config.get_speed()
	var _speed_mult := speed_config.get_speed_multiplier()
	
	# direction_sign: 1.0 for forward, -1.0 for backward
	var forward_vec := _player.basis.z * direction_sign
	_player.velocity = forward_vec * _speed * _speed_mult


func move_strafe_with_forward(input_: InputPackage, direction_sign: float, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed := speed_config.get_speed()
	var _speed_mult := speed_config.get_speed_multiplier()
	
	var forward_vec := -_player.global_basis.z
	var right_vec := _player.global_basis.x
	
	var forward_component := input_.input_direction.y # raw forward/backward input component
	
	# final dir by combining raw f input and the state-controlled strafe direction
	var desired_direction := (forward_vec * forward_component + right_vec * direction_sign)
	
	if desired_direction.is_zero_approx():
		_player.velocity = Vector3.ZERO
		return
	
	var final_velocity := desired_direction.normalized() * _speed * _speed_mult
	_player.velocity = final_velocity


func look_at_target(delta: float, speed_config: SpeedConfig = null) -> void:
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _ang_speed := speed_config.get_angular_sp()
	
	if area_awareness.is_camera_locked():
		var target_pos := area_awareness.get_camera_locked_target().global_position
		target_pos.y = _player.global_position.y

		var dir_to_target := _player.global_position.direction_to(target_pos)
		var face_dir := _player.global_basis.z
		
		var remaining_angle := face_dir.signed_angle_to(dir_to_target, Vector3.UP)
		
		var max_rot_this_frame := _ang_speed * delta # maximum rotation allowed in this single frame
		var rotation_this_frame := clampf(remaining_angle, -max_rot_this_frame, max_rot_this_frame)
		
		_player.rotate_y(rotation_this_frame)
		# prints("~~~~", rotation_this_frame)

# endregion


## VELOCITY BY INPUT LOGIC
# region

# region: big TODO
## Player SM, fancy camera and input gathering are nicely separated in diff systems
## But this essential func needs them all together and => a lot of the bad symptoms:
##    - it's the only logic of such sort (and it's not just glue but math going on here)
##    - it makes every placement of it wrong (in pl movement it almost ok)
##    - constants like __VEL_SPEED are separated from every other loco config
## 
## In order to understand why that happened and what to do we need to either rethink the PlayerPack.
## (like may be a new abstract 'input' layer which knows about both: input gathering and camera data)
## Or rewrite current logic. I suspect same can be done easier.
## And it's much simplier to just leave this small ball of mud here.
# endregion
var __VEL_SPEED: float = 3.0
func __velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input_.forward_input
	var orbit_speed := input_.orbit_input

	if area_awareness.is_camera_locked():
		forward_speed *= -1
		orbit_speed *= -1
	
	var grounded_target: Vector3
	if area_awareness.is_camera_locked():
		grounded_target = _player.fancy_camera.locked_target.global_position
	else:
		grounded_target = _player.fancy_camera.nest.global_position
	grounded_target.y = _player.global_position.y

	if forward_speed != 0.0:
		_velocity -= _player.global_position.direction_to(grounded_target) * forward_speed * __VEL_SPEED

	if orbit_speed != 0.0:
		var d: float = orbit_speed * __VEL_SPEED * delta
		var target_direction := grounded_target - _player.global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - _player.global_position
		_velocity += d_vector / delta
	return _velocity


func __angle_between_player_and_input(input_: InputPackage, delta: float, __log: bool = false) -> float:
	var face_dir := _player.basis.z
	var input_dir := __velocity_by_input(input_, delta).normalized()
	var angle := face_dir.signed_angle_to(input_dir, Vector3.UP)
	# if __log: print_.dev("\t _face_dir", face_dir, "_input_dir", pp.vec3(input_dir))
	return angle


# endregion


## __LOGGING
# region

func __pp_vel_y() -> String:
	return pp.s(get_curr_y_velocity())

func __pp_gl_pos_y() -> String:
	return pp.s(get_player().global_position.y)

func __pp_vel_xz_len() -> String:
	return pp.s(get_curr_xz_velocity_len())

func __pp_vel() -> String:
	return pp.s("vel.y / gl_pos.y / vel.xz.len", __pp_vel_y(), __pp_gl_pos_y(), __pp_vel_xz_len())


func __log_(...parts: Array):
	print_.psm("Pl Movement", pp.list_(parts))
# endregion
