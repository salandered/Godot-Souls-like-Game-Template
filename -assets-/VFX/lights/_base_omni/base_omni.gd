@tool
@icon("res://-assets-/x_icons/yellow/icon_light_bulb.png")

@abstract
class_name BaseOmni
extends Node3DSystem


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

@export var indirect_energy: float = 1.0:
	set(value):
		indirect_energy = value
		if is_node_ready(): _apply_light_settings()

@export var attenuation: float = 1.5:
	set(value):
		attenuation = value
		if is_node_ready(): _apply_light_settings()

@export var volumetric_fog_energy: float = 1.0:
	set(value):
		volumetric_fog_energy = value
		if is_node_ready(): _apply_light_settings()

@export var cast_shadows: bool = true:
	set(value):
		cast_shadows = value
		if is_node_ready(): _apply_light_settings()

@export var bake_mode: Light3D.BakeMode = Light3D.BAKE_DYNAMIC:
	set(value):
		bake_mode = value
		if is_node_ready(): _apply_light_settings()

@export_group("Effects")
@export var add_mist: bool = false:
	set(value):
		add_mist = value
		if is_node_ready(): _apply_mist()

@export var mist_particles_amount: int = 10:
	set(value):
		mist_particles_amount = value
		if is_node_ready(): _apply_mist()

@export var mist_particle_scale: float = 1.0:
	set(value):
		mist_particle_scale = value
		if is_node_ready(): _apply_mist()


@export_group("Material")
@export var color: Color = Color("ff9e49"): # Default orange-ish fire color
	set(value):
		color = value
		if is_node_ready(): _apply_light_settings()

@export_group("Debug")
@export var __csg_editor_view: bool = true:
	set(value):
		__csg_editor_view = value
		if is_node_ready(): _apply_debug_visuals()
@export var __csg_game_view: bool = false:
	set(value):
		__csg_game_view = value
		if is_node_ready(): _apply_debug_visuals()

# endregion

# region Dependencies

@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var puff_fog: PuffFog = %PuffFog
@onready var __csg: CSGSphere3D = %__csg


func __hard_dependencies() -> Array[Object]:
	return [omni_light_3d]

func __soft_dependencies() -> Array[Object]:
	return [puff_fog, __csg]

# endregion

func _ready() -> void:
	if not __perform_validation():
		return
		
	_apply_all_properties()
	_ready_implementation()

	if not Engine.is_editor_hint():
		u.hide_dev_visuals(self)
		_ready_implementation_non_editor()


@abstract func _ready_implementation()


@abstract func _ready_implementation_non_editor()


func _apply_all_properties() -> void:
	_apply_light_settings()
	_apply_mist()
	_apply_debug_visuals()


# region Apply Functions

func _apply_light_settings() -> void:
	if omni_light_3d:
		omni_light_3d.omni_range = radius
		omni_light_3d.light_energy = energy
		omni_light_3d.light_indirect_energy = indirect_energy
		omni_light_3d.light_color = color
		omni_light_3d.omni_attenuation = attenuation
		omni_light_3d.light_volumetric_fog_energy = volumetric_fog_energy
		omni_light_3d.shadow_enabled = cast_shadows
		omni_light_3d.light_bake_mode = bake_mode


func _apply_mist() -> void:
	if puff_fog:
		puff_fog.set_effect_enabled(add_mist)
		puff_fog.particles_amount = mist_particles_amount
		puff_fog.particle_scale = mist_particle_scale


func _apply_debug_visuals() -> void:
	if not __csg:
		return
	if Engine.is_editor_hint():
		__csg.visible = __csg_editor_view
	else:
		__csg.visible = __csg_game_view

# endregion
