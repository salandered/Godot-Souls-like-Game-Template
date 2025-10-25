# @abstract
extends ActionTimeManagement
class_name EnemyStateUtils


var me: BaseEnemyCharacter
var e_movement: EnemyMovement

# @abstract func get_me() -> BaseEnemyCharacter


func get_player() -> Princess:
	return me.player

#

func distance_to_player() -> float:
	return e_movement.distance_to_player()


func distance_to_(target: Node3D) -> float:
	return e_movement.distance_to_(target)


func abs_angle_to_player() -> float:
	return e_movement.abs_angle_to_player()


func signed_angle_to_player() -> float:
	return e_movement.signed_angle_to_player()


func direction_to_(target: Variant) -> Vector3:
	return e_movement.direction_to_(target)
