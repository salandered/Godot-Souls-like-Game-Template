class_name SimpleTarget
extends Node3DSystem

@export var label: String
@onready var camera_target: EnemyCameraTarget = %CameraTarget
@onready var hit_area: SimpleTargetHitArea = %HitArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func __hard_dependencies() -> Array[Object]:
	return [
		animation_player,
		hit_area,
		camera_target
	]


func __hard_validation() -> bool:
	var r := AnimUtils.safe_has_animation(animation_player, AnimID.rotate_on_hit)
	return r


class AnimID:
	const rotate_on_hit = "rotate_on_hit"
	const rotate_on_hit_super = "rotate_on_hit_super"


func _ready() -> void:
	if not label:
		label = str(get_path())

	if camera_target:
		camera_target.label = label
		camera_target.initialise(self)

	if __perform_validation():
		hit_area.SIG_hit.connect(_on_my_area_hit)


func _on_my_area_hit(payload: Dictionary[String, Variant]):
	var damage := 10.0
	var _r := SigUtils.safe_get_int_float_payload_value(payload, GlobalSignal.payload_damage_field)
	if not _r.err:
		damage = _r.value
	var _speed_scale := damage / 16.0
	animation_player.stop()
	if _speed_scale > 2.0:
		PlayerStats.set_simple_target_super_rotate()
		animation_player.play(AnimID.rotate_on_hit_super, 0.2, _speed_scale / 1.5)
	else:
		animation_player.play(AnimID.rotate_on_hit, 0.2, _speed_scale)
	__log_("playing", AnimID.rotate_on_hit, "_speed_scale", _speed_scale, "based on damage", damage)


func __LOG_B() -> bool:
	return false
