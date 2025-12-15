extends Node3D

class_name SittingSceneWrapper


@onready var general_skeleton: Skeleton3D = %GeneralSkeleton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func get_general_skeleton() -> Skeleton3D:
	return general_skeleton
	
func get_animation_player() -> AnimationPlayer:
	return animation_player
