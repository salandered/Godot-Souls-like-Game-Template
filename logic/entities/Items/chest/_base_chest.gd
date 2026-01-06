@tool
@icon("res://-assets-/x_icons/chest/icon_chest_3.png")

@abstract
class_name BaseChest
extends Node3DSystem


## things like mateterial can be changed using scene inheritance


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dev_cam: Camera3D = %dev_cam
@onready var interact_area: InteractArea = %InteractArea

@onready var item_pivot: Marker3D = $ItemPivot


@export var item_scene: PackedScene
@export var override_label_y_offset: float = 1.0:
	set(value):
		override_label_y_offset = value
		if is_node_ready(): _set_label_y_offset()

var item: BasePickItem


func __hard_dependencies() -> Array[Object]:
	return [
		animation_player
	]

func __soft_dependencies() -> Array[Object]:
	return [
		interact_area,
		item
	]

class AnimID:
	const open = "open"


func _ready() -> void:
	_set_label_y_offset()
	
	
	if not Engine.is_editor_hint():
		if item_scene:
			var _item = item_scene.instantiate()
			if _item is not BasePickItem:
				__log_warn("_item is not BasePickItem")
				item = null
			else:
				item = _item
				add_child(item)
				item.global_position = item_pivot.global_position
				_item.set_interact_area_enable(false)
	
		if __perform_validation():
			animation_player.animation_finished.connect(_on_animation_finished)
			interact_area.SIG_interacted.connect(_on_my_area_interacted)


func __hard_validation() -> bool:
	var r = AnimUtils.safe_has_animation(animation_player, AnimID.open)
	return r


func open():
	if not __validation_ok():
		return
	__log_("open", "opening")
	
	animation_player.play(AnimID.open)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.open:
			__log_("_on_animation_finished", "open")
			if item:
				item.set_interact_area_enable(true)


func _on_my_area_interacted():
	if not interact_area.ENABLED:
		__log_("_on_my_area_interacted", "not interact_area.enabled")
		return
	interact_area.ENABLED = false
	__log_("_on_my_area_interacted", "triggered")
	open()


func _set_label_y_offset() -> void:
	if interact_area:
		interact_area.label_y_offset = override_label_y_offset
# func _input(event: InputEvent) -> void:
# 	if not OS.is_debug_build():
# 		return
		
# 	if event.is_action_pressed(RawAction.DEV_H):
# 		open()
