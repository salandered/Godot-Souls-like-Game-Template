extends Node3D
class_name AirWave2


@onready var csg_box_3d: CSGBox3D = %CSGBox3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var animation_name: String = "explode"

func _ready() -> void:
	csg_box_3d.visible = false
	
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
