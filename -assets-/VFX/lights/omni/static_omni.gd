@tool
class_name StaticOmni
extends BaseOmni


# region Exports

@export_group("Light Settings")
@export var radius: float = 3.6:
	set(value):
		radius = value
		if is_node_ready(): _apply_light_settings()

@export var energy: float = 3.8:
	set(value):
		energy = value
		if is_node_ready(): _apply_light_settings()


# endregion


func _ready_implementation() -> void:
	_apply_static_omni_settings()


# region Apply Functions

func _apply_static_omni_settings() -> void:
	if omni_light_3d:
		omni_light_3d.omni_range = radius
		omni_light_3d.light_energy = energy

# endregion
