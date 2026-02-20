@tool
@icon("res://-assets-/x_icons/chest/icon_chest_3.png")

@abstract
class_name BaseChest
extends Node3DSystem


## things like material can be changed using scene inheritance


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dev_cam: Camera3D = %dev_cam
@onready var interact_area: InteractArea = %InteractArea

@onready var item_pivot: Marker3D = $ItemPivot


@export var item_scene: PackedScene

## nullable after validation
var item: BasePickItem


func __hard_dependencies() -> Array:
	return [
		animation_player,
		item_scene
	]

func __soft_dependencies() -> Array:
	return [
		interact_area,
	]

class AnimID:
	const open = "open"


func _ready() -> void:
	if not u.is_editor():
		if __perform_validation():
			var _item := item_scene.instantiate()
			if _item is not BasePickItem:
				__log_warn("_item is not BasePickItem")
				item = null
			else:
				item = _item
				add_child(item)
				item.global_position = item_pivot.global_position
				item.set_interact_area_monitor_enable(false)

			animation_player.animation_finished.connect(_on_animation_finished)
			interact_area.SIG_interacted.connect(_on_my_area_interacted)


func __hard_validation() -> bool:
	var r := AnimUtils.safe_has_animation(animation_player, AnimID.open)
	return r


func open():
	__log_("open", "opening")
	
	animation_player.play(AnimID.open)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.open:
			__log_("_on_animation_finished", "open")
			if item:
				item.set_interact_area_monitor_enable(true)


func _on_my_area_interacted():
	if not interact_area.MONITOR_ENABLED:
		__log_("_on_my_area_interacted", "not interact_area.MONITOR_ENABLED")
		return
	interact_area.set_monitor_enable(false)
	__log_("_on_my_area_interacted", "triggered")
	open()


# func _input(event: InputEvent) -> void:
# 	if u.is_release():
# 		return
		
# 	if event.is_action_pressed(RawAction.DEV_H):
# 		open()
