@abstract
class_name BasePickItem
extends Node3DSystem


@onready var interact_area: InteractArea = %InteractArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer


## DOCS: frees itself on 'pick' animation finished


func __hard_dependencies() -> Array[Object]:
	return [
		interact_area
	]

func __soft_dependencies() -> Array[Object]:
	return [
		animation_player
	]


class AnimID:
	const pick = "pick"


func _ready() -> void:
	u.set_all_descendant_asp_3d_default_bus(self)
	
	if __validate_dependencies():
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
	
	_on_my_area_interacted_implementation()
	
	## shoudld be in the end
	animation_player.play(AnimID.pick)

	
@abstract func _on_my_area_interacted_implementation()


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.pick:
			__log_("_on_animation_finished", "pick, will queue free")
			queue_free()


func __LOG_INDENT() -> int:
	return LogToggler.ITEM.BASE_PICK
