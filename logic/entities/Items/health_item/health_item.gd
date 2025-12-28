class_name HealthItem
extends Node3DSystem


@onready var interact_area: InteractArea = %InteractArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func get_hard_dependencies() -> Array[Object]:
	return [
		interact_area
	]

func get_soft_dependencies() -> Array[Object]:
	return [
		animation_player
	]


class AnimID:
	const pick = "pick"


func _ready() -> void:
	u.set_all_descendant_asp_3d_default_bus(self)
	
	if __validate_deps_set_init():
		interact_area.SIG_interacted.connect(_on_my_area_interacted)
		animation_player.animation_finished.connect(_on_animation_finished)


## public
func set_interact_area_enable(value: bool):
	__log_("set_interact_area_enable", value)
	interact_area.ENABLED = value


func _on_my_area_interacted():
	if not interact_area.ENABLED:
		__log_("_on_my_area_interacted", "not interact_area.enabled")
		return
	interact_area.ENABLED = false
	
	__log_("_on_my_area_interacted", "triggered")

	var signal_data := GlobalSignal.player_change_health
	u.safe_emit(signal_data, {GlobalSignal.payload_amount_field: + 30}, false)
	
	animation_player.play(AnimID.pick)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.pick:
			__log_("_on_animation_finished", "pick, will queue free")
			queue_free()
