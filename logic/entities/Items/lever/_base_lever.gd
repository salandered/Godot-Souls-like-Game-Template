@abstract
class_name BaseLever
extends Node3DSystem


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var interact_area: InteractArea = %InteractArea


signal SIG_lever_switched


func __hard_dependencies() -> Array:
	return [
		animation_player,
		interact_area,
	]

func __soft_dependencies() -> Array:
	return [
	]


func __hard_validation() -> bool:
	var r := AnimUtils.safe_has_animation(animation_player, AnimID.lever_switch)
	return r


class AnimID:
	const lever_switch = &"lever_switch"


func _ready() -> void:
	if __perform_validation():
		interact_area.SIG_interacted.connect(_on_my_area_interacted)
		interact_area.set_monitor_enable(true)


func _switch_lever():
	__log_("_switch_lever")
	if not animation_player.is_playing():
		animation_player.play(AnimID.lever_switch)


func _on_my_area_interacted():
	__log_("_on_my_area_interacted", "triggered")
	_switch_lever()


func _on_switch_inside_anim():
	__log_("_on_switch_inside_anim", "triggered")
	SigUtils.safe_emit_no_payload(SIG_lever_switched, false)
	_on_switch_inside_anim_implementation()


func _on_switch_inside_anim_implementation():
	pass

## 

func __LOG_B() -> bool:
	return false
