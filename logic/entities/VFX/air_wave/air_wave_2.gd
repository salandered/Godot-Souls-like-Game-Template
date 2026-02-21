extends Node3DLogger
class_name AirWave2


@onready var __dev_csg_box_3d: CSGBox3D = %CSGBox3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var air_wave_mesh: MeshInstance3D = %AirWaveMesh

class AnimID:
	const explode := "explode"
	const big_explode := "explode_big"


var default_anim_id := AnimID.explode


func _ready() -> void:
	self.visible = true
	__dev_csg_box_3d.visible = false
	__log_("ready, default anim is", default_anim_id)

	animation_player.animation_finished.connect(_on_animation_finished)


func spawn_shockwave(anim_id: StringName, y_shift: float = 0.0):
	_spawn_shockwave(self.global_position, anim_id, y_shift)


func spawn_shockwave_at_position(glob_position: Vector3, anim_id: StringName, y_shift: float = 0.0):
	_spawn_shockwave(glob_position, anim_id, y_shift)


func _spawn_shockwave(glob_position: Vector3, anim_id: StringName, y_shift: float = 0.0):
	self.global_position = glob_position
	self.global_position.y += y_shift
	_play_anim(anim_id)


func _play_anim(anim_id):
	if AnimUtils.safe_has_animation(animation_player, anim_id, WL.WARN):
		animation_player.play(anim_id)
	else:
		__log_warn_soft(pp.s("no such anim_id, won't be playing", pp.anim_n(anim_id)))
		_cleanup()


func _cleanup():
	__log_("queue_free myself")
	queue_free()


func _on_animation_finished(_anim_name: String) -> void:
	_cleanup()


## to override
func __LOG_B() -> bool:
	return false
