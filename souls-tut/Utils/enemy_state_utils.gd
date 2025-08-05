extends StateUtils
class_name EnemyStateUtils


@export var me: CharacterBody3D
@export var player: CharacterBody3D

func distance_to_player() -> float:
	return me.global_position.distance_to(player.global_position)

func angle_to_player() -> float:
	return me.basis.z.angle_to(projected_direction_to_player())

func direction_to_player() -> Vector3:
	return me.global_position.direction_to(player.global_position)

func projected_direction_to_player() -> Vector3:
	return me.global_position.direction_to(get_projected_player_pos())

func get_projected_player_pos() -> Vector3:
	var player_pos = player.global_position
	player_pos.y = me.global_position.y
	return player_pos
