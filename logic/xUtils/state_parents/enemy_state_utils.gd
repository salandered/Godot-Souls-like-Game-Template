# @abstract
extends StateUtils
class_name EnemyStateUtils


var me: BaseEnemyCharacter

# @abstract func get_me() -> BaseEnemyCharacter


func get_player() -> Princess:
	return me.player

#
func distance_to_player() -> float:
	return me.global_position.distance_to(get_player().global_position)

func distance_to_(target: Node3D) -> float:
	return me.global_position.distance_to(target.global_position)

func angle_to_player() -> float:
	return me.basis.z.angle_to(projected_direction_to_player())

func direction_to_player() -> Vector3:
	return me.global_position.direction_to(get_player().global_position)

func direction_to_(target: Variant) -> Vector3:
	if target is Node3D:
		return me.global_position.direction_to(target.global_position)
	elif target is Vector3:
		return me.global_position.direction_to(target)
	else:
		push_error("Invalid target type for direction_to_")
		return Vector3.ZERO

func look_at_player(grounded: bool = false):
	var target := get_player().global_position
	if grounded:
		target = get_projected_player_pos()
	u.safe_look_at(me, target, Vector3.UP, true)

func projected_direction_to_player() -> Vector3:
	return me.global_position.direction_to(get_projected_player_pos())

func get_projected_player_pos() -> Vector3:
	var player_pos := get_player().global_position
	player_pos.y = me.global_position.y
	return player_pos
