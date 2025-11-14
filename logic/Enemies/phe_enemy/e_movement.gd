extends BaseCharacterMovement
class_name EnemyMovement


var me: BaseEnemyCharacter

@onready var animator_manager: EnemyAnimatorManager = %AnimatorManager
@onready var enemy_awareness: EnemyAwareness = %EnemyAwareness


func get_character() -> BaseEnemyCharacter:
	return me


func get_player() -> Princess:
	return get_character().player


## PLAYER UTILS
# region

func distance_to_player() -> float:
	return get_character().global_position.distance_to(get_player().global_position)


func square_distance_to_player() -> float:
	return get_character().global_position.distance_squared_to(get_player().global_position)


func distance_to_(target: Node3D) -> float:
	return get_character().global_position.distance_to(target.global_position)


func abs_angle_to_player() -> float:
	return get_character().basis.z.angle_to(projected_direction_to_player())

func signed_angle_to_player() -> float:
	# returns signed angle (-π to π)
	return get_character().basis.z.signed_angle_to(projected_direction_to_player(), Vector3.UP)


func direction_to_player() -> Vector3:
	return get_character().global_position.direction_to(get_player().global_position)


func projected_direction_to_player() -> Vector3:
	return get_character().global_position.direction_to(get_player_position_grounded())


func get_player_position_grounded() -> Vector3:
	var player_pos := get_player().global_position
	player_pos.y = get_character().global_position.y
	return player_pos


# endregion


## MOVING
# region


func look_at_player(grounded: bool = false):
	var target := get_player().global_position
	if grounded:
		target = get_player_position_grounded()
	u.safe_look_at(me, target, Vector3.UP, true)


func move_rotate_towards_player(delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(delta, speed_config)
	_move_toward_player(angle, speed_config)
	get_character().rotate_y(angle.value)


func rotate_towards_player(delta: float, speed_config: SpeedConfig = null, angle_adjustment: float = 0.0):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(delta, speed_config, angle_adjustment)
	get_character().rotate_y(angle.value)


func _calculate_allowed_angle(delta: float, speed_config: SpeedConfig, angle_adjustment: float = 0.0) -> AllowedAngle:
	var _angular_speed := speed_config.get_angular_sp()

	var target_dir := projected_direction_to_player()
	if angle_adjustment != 0.0:
		target_dir = target_dir.rotated(Vector3.UP, angle_adjustment)
		
	var angle := face_dir().signed_angle_to(target_dir, Vector3.UP)
	
	if abs(angle) >= _angular_speed * delta: # reads as 'max rotation allowed in this frame'
		return AllowedAngle.new(sign(angle) * _angular_speed * delta, true)
	else:
		return AllowedAngle.new(angle, false)


func _move_toward_player(angle: AllowedAngle, speed_config: SpeedConfig):
	var _speed := speed_config.get_speed()
	var _turn_speed := speed_config.get_turn_speed()
	var _speed_mult := speed_config.get_speed_multiplier()

	var face_dir_rotated := face_dir().rotated(Vector3.UP, angle.value)
	
	if angle.cut: # sharp turn - slower speed
		get_character().velocity = face_dir_rotated * _turn_speed * _speed_mult
	else:
		get_character().velocity = face_dir_rotated * _speed * _speed_mult

# endregion


## MOVING WITH ROOT
# region 


func move_with_root(delta: float, scale_factor: float = 1.0, y_included: bool = true, scale_y: bool = true, __log: bool = false) -> void:
	var delta_pos := animator_manager.get_root_motion_position(not y_included)
	if __log: print("ROOT MOTION - Raw delta_pos: ", delta_pos, " | y_included: ", y_included)
	
	if y_included:
		var _new_vel := (get_character().get_quaternion() * delta_pos / delta)
		if scale_y:
			_new_vel *= scale_factor
		else:
			# Scale only X and Z, keep Y unscaled
			_new_vel.x *= scale_factor
			_new_vel.z *= scale_factor
		if __log: print("ROOT MOTION - New velocity (Y included, scale_y: ", scale_y, "): ", _new_vel)
		get_character().velocity = _new_vel
	else:
		var __new_vel := (get_character().get_quaternion() * delta_pos / delta) * scale_factor
		__new_vel.y = get_character().velocity.y
		if __log: print("ROOT MOTION - New velocity (Y preserved): ", __new_vel, " | Old Y: ", get_character().velocity.y)
		get_character().velocity = __new_vel


## STRAFE
# region

## _direction is +-1. -1 means right
func orbit(_direction: int = 1, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed := speed_config.get_speed()
	
	var strafe_vec := Vector3.UP.cross(direction_to_player()) * _speed * _direction
	strafe_vec.y = get_character().velocity.y # preserve Y-velocity for gravity
	get_character().velocity = strafe_vec

# endregion
