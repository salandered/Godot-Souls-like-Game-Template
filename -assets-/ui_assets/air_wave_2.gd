extends Node3D
class_name AirWave2


@export var spawn_on_ready: bool = false
@onready var csg_box_3d: CSGBox3D = %CSGBox3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var air_wave_mesh: MeshInstance3D = %AirWaveMesh

var anim_name: String = "explode"

func _ready() -> void:
	self.visible = true
	csg_box_3d.visible = false
	prints("~~~_ready", anim_name)
	if spawn_on_ready:
		spawn_shockwave(anim_name)
	else:
		air_wave_mesh.visible = false


func spawn_shockwave(anim_name_: String, y_shift: float = 0.0):
	_spawn_shockwave(self.global_position, anim_name_, y_shift)


func spawn_shockwave_at_position(glob_position: Vector3, anim_name_: String, y_shift: float = 0.0):
	_spawn_shockwave(glob_position, anim_name_, y_shift)


func _spawn_shockwave(glob_position: Vector3, anim_name_: String, y_shift: float = 0.0):
	self.global_position = glob_position
	self.global_position.y += y_shift
	if animation_player.has_animation(anim_name_):
		prints("~~~animation_player.play(animation_name)", anim_name_)
		animation_player.play(anim_name_)
	else:
		prints("~~~no anim", anim_name_)
