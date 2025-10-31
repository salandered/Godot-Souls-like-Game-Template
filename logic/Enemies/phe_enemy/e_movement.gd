extends Node
# see PlayerMovement for a reference
class_name EnemyMovement


var me: BaseEnemyCharacter

@onready var animator_manager: EnemyAnimatorManager = %AnimatorManager
@onready var enemy_awareness: EnemyAwareness = %EnemyAwareness


class AllowedAngle:
	var value: float
	var cut: float

	func _init(_value, _cut: bool = false) -> void:
		value = _value
		cut = _cut


func get_player() -> Princess:
	return me.player


## PLAYER UTILS
# region: code

func distance_to_player() -> float:
	return me.global_position.distance_to(get_player().global_position)


func square_distance_to_player() -> float:
	return me.global_position.distance_squared_to(get_player().global_position)


func distance_to_(target: Node3D) -> float:
	return me.global_position.distance_to(target.global_position)


func abs_angle_to_player() -> float:
	return me.basis.z.angle_to(projected_direction_to_player())

func signed_angle_to_player() -> float:
	# returns signed angle (-π to π)
	return me.basis.z.signed_angle_to(projected_direction_to_player(), Vector3.UP)


func direction_to_player() -> Vector3:
	return me.global_position.direction_to(get_player().global_position)


func projected_direction_to_player() -> Vector3:
	return me.global_position.direction_to(get_player_position_grounded())


func get_player_position_grounded() -> Vector3:
	var player_pos := get_player().global_position
	player_pos.y = me.global_position.y
	return player_pos


# endregion


## BASIC UTILS
# region: code


func direction_to_(target: Variant) -> Vector3:
	if target is Node3D:
		return me.global_position.direction_to(target.global_position)
	elif target is Vector3:
		return me.global_position.direction_to(target)
	else:
		push_error("Invalid target type for direction_to_")
		return Vector3.ZERO


func face_dir() -> Vector3:
	return me.basis.z


func get_curr_velocity_len() -> float:
	return me.velocity.length()

# endregion


## MOVING
# region: code


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
	me.rotate_y(angle.value)


func rotate_towards_player(delta: float, speed_config: SpeedConfig = null, angle_adjustment: float = 0.0):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(delta, speed_config, angle_adjustment)
	me.rotate_y(angle.value)


func _calculate_allowed_angle(delta: float, speed_config: SpeedConfig, angle_adjustment: float = 0.0) -> AllowedAngle:
	var _angular_speed := speed_config.get_angular_sp()

	var target_dir = projected_direction_to_player()
	if angle_adjustment != 0.0:
		target_dir = target_dir.rotated(Vector3.UP, angle_adjustment)
		
	var angle = face_dir().signed_angle_to(target_dir, Vector3.UP)
	
	if abs(angle) >= _angular_speed * delta: # reads as 'max rotation allowed in this frame'
		return AllowedAngle.new(sign(angle) * _angular_speed * delta, true)
	else:
		return AllowedAngle.new(angle, false)


func _move_toward_player(angle: AllowedAngle, speed_config: SpeedConfig):
	var _speed := speed_config.get_speed()
	var _turn_speed := speed_config.get_turn_speed()
	var _speed_mult := speed_config.get_speed_multiplier()

	var face_dir_rotated = face_dir().rotated(Vector3.UP, angle.value)
	
	if angle.cut: # sharp turn - slower speed
		me.velocity = face_dir_rotated * _turn_speed * _speed_mult
	else:
		me.velocity = face_dir_rotated * _speed * _speed_mult

# endregion


func apply_gravity(delta) -> bool:
	if not me.is_on_floor():
		me.velocity.y -= u.gravity * delta
		return true
	return false


## MOVING WITH ROOT
# region: code 

func move_with_root(delta: float) -> void:
	var delta_pos = animator_manager.get_root_motion_position(true)
	me.velocity = me.get_quaternion() * delta_pos / delta
	# need this?
	# var new_vel = me.get_quaternion() * delta_pos / delta
	# new_vel.y = me.velocity.y
	# me.velocity = new_vel

func move_with_root_scaled(delta: float, scale_factor: float) -> void:
	var delta_pos = animator_manager.get_root_motion_position(true)
	delta_pos.y = 0
	var new_vel = (me.get_quaternion() * delta_pos / delta) * scale_factor
	new_vel.y = me.velocity.y
	me.velocity = new_vel

## STRAFE
# region: code

## _direction is +-1. -1 means right
func orbit(_direction: int = 1, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed := speed_config.get_speed()
	
	var strafe_vec = Vector3.UP.cross(direction_to_player()) * _speed * _direction
	strafe_vec.y = me.velocity.y # preserve Y-velocity for gravity
	me.velocity = strafe_vec

# endregion
