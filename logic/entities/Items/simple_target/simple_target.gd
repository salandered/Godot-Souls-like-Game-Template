class_name SimpleTarget
extends Node3DSystem

@export var label: String
@onready var camera_target: EnemyCameraTarget = %CameraTarget
@onready var hit_area: MonitorPlHitSigArea = %HitArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer


var last_hit: HitData = null


func __hard_dependencies() -> Array:
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
	const rotate_on_hit_clock = "rotate_on_hit_clock"
	const rotate_on_hit_super = "rotate_on_hit_super"


func _ready() -> void:
	if not label:
		label = str(get_path())

	if camera_target:
		camera_target.label = label
		camera_target.initialise(self )

	if __perform_validation():
		hit_area.SIG_hit.connect(_on_my_area_hit)


func _on_my_area_hit(payload: Dictionary[String, Variant]):
	var hit_damage := 10.0
	var _r := SigUtils.safe_get_variant_payload_value(payload, SPS.hit_data_field, false)
	if not _r.err and _r.value is HitData:
		last_hit = _r.value
		hit_damage = last_hit.damage
	play_anim(hit_damage, last_hit.attack_dir)
	_on_my_area_hit_imp()


func _on_my_area_hit_imp():
	pass


func play_anim(hit_damage: float, attack_dir: AttackDirection.Dir):
	var _speed_scale := hit_damage / 16.0
	var _anim_id := AnimID.rotate_on_hit

	if _speed_scale > 2.0:
		_anim_id = AnimID.rotate_on_hit_super
		PlayerStats.set_simple_target_super_rotate()
		_speed_scale /= 1.5

	# reverse 
	if attack_dir in [AttackDirection.Dir.LEFT, AttackDirection.Dir.STAB]:
		_anim_id = AnimID.rotate_on_hit_clock


	animation_player.stop()
	animation_player.play(_anim_id, 0.2, _speed_scale)
	__log_("playing", _anim_id, "_speed_scale", _speed_scale, "based on damage", hit_damage)


func __LOG_B() -> bool:
	return false
