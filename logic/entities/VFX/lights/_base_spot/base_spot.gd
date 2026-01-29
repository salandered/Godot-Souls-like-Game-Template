@tool
@icon("res://-assets-/x_icons/copper/icon_light_bulb.png")

class_name BaseSpot
extends SpotLight3DSystem

@export_group("Effects")
@export var add_mist: bool = false:
	set(value):
		add_mist = value
		if is_node_ready(): _apply_mist()


@export_group("Debug")
@export var __csg_editor_view: bool = true:
	set(value):
		__csg_editor_view = value
		if is_node_ready(): _apply_debug_visuals()
@export var __csg_game_view: bool = false:
	set(value):
		__csg_game_view = value
		if is_node_ready(): _apply_debug_visuals()


@onready var puff_fog: PuffFog = %PuffFog
@onready var __csg: CSGSphere3D = %__csg


func __hard_dependencies() -> Array:
	return []

func __soft_dependencies() -> Array:
	return [puff_fog, __csg]

# endregion

func _ready() -> void:
	if not __perform_validation():
		return
		
	_apply_all_properties()

	if not Engine.is_editor_hint():
		u.hide_dev_visuals(self)


func _apply_all_properties() -> void:
	_apply_mist()
	_apply_debug_visuals()


# region Apply Functions


func _apply_mist() -> void:
	if puff_fog: puff_fog.set_effect_enabled(add_mist)


func _apply_debug_visuals() -> void:
	if not __csg:
		return
	if Engine.is_editor_hint():
		__csg.visible = __csg_editor_view
	else:
		__csg.visible = __csg_game_view

# endregion
