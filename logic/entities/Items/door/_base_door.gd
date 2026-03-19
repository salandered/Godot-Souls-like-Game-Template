@abstract
class_name BaseDoor
extends Node3DSystem


@export var initial_state: DoorState = DoorState.CLOSED_UNLOCKED
@export var show_door: bool = true

@onready var visuals: Node3D = %Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dev_cam: Camera3D = %dev_cam
@onready var interact_area: InteractArea = %InteractArea
@onready var __csg_pivot: CSGCylinder3D = %__csg_pivot


enum DoorState {
	CLOSED_UNLOCKED,
	CLOSED_LOCKED,
	# OPEN # future
}

var current_state: DoorState = DoorState.CLOSED_UNLOCKED


func __hard_dependencies() -> Array:
	return [
		animation_player
	]

func __soft_dependencies() -> Array:
	return [
		interact_area,
		visuals
	]

class AnimID:
	const open_push = &"open_push"
	const cant_open_locked = &"cant_open_locked"


func _ready() -> void:
	current_state = initial_state

	if visuals:
		visuals.visible = show_door

	if __csg_pivot:
		__csg_pivot.visible = false

	if __perform_validation():
		animation_player.animation_finished.connect(_on_animation_finished)
		interact_area.SIG_interacted.connect(_on_my_area_interacted)


func __hard_validation() -> bool:
	var r := AnimUtils.safe_has_animation(animation_player, AnimID.open_push) \
		and AnimUtils.safe_has_animation(animation_player, AnimID.cant_open_locked)
	return r


func open_push():
	_play_anim(AnimID.open_push)

func cant_open_locked():
	_play_anim(AnimID.cant_open_locked)


func _play_anim(anim_id: StringName):
	if not __validation_ok():
		return
	__log_(anim_id, "opening")
	
	animation_player.play(anim_id)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.open_push:
			__log_(__pp_prefix("_on_animation_finished"), AnimID.open_push)


func _on_my_area_interacted():
	if not interact_area.MONITOR_ENABLED:
		__log_(__pp_prefix("_on_my_area_interacted"), "not interact_area.MONITOR_ENABLED")
		return

	__log_(__pp_prefix("_on_my_area_interacted"), "triggered")
	match current_state:
		DoorState.CLOSED_UNLOCKED:
			interact_area.set_monitor_enable(false)
			open_push()
		DoorState.CLOSED_LOCKED:
			interact_area.set_monitor_enable(true)
			cant_open_locked()


# func _input(event: InputEvent) -> void:
# 	if eu.is_release():
# 		return
		
# 	if event.is_action_pressed(RawAction.DEV_H):
# 		open_push()


func __pp_prefix(prefix: String) -> String:
	return pp.s(prefix, current_state)
