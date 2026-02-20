@tool
@icon("res://-assets-/x_icons/red/icon_particle.png")
@abstract
class_name BaseParticlesEffect
extends Node3DLogger


@export var particles_amount: int = 10:
	set(value):
		particles_amount = value
		if is_node_ready(): _apply_amount()

@export var lifetime: float = 9.0:
	set(value):
		lifetime = value
		if is_node_ready(): _apply_lifetime()

@export var lifetime_randomness: float = 0.2:
	set(value):
		lifetime_randomness = value
		if is_node_ready(): _apply_lifetime_randomness()

@export var preprocess: float = 0.0:
	set(value):
		preprocess = value
		if is_node_ready(): _apply_preprocess()

@export var particle_scale: float = 1.0:
	set(value):
		particle_scale = value
		if is_node_ready(): _apply_scale()

## Controls the area where particles spawn.
## Only works if Emission Shape is set to BOX.
@export var emission_box_extents: Vector3 = Vector3(1, 1, 1):
	set(value):
		emission_box_extents = value
		if is_node_ready(): _apply_emission_extents()

@export_group("Material Settings")
@export var color_multiplier: Color = Color.WHITE:
	set(value):
		color_multiplier = value
		if is_node_ready(): _apply_color()

## takes effect only if particles use normal texture
@export var normal_strength: float = 12.0:
	set(value):
		normal_strength = value
		if is_node_ready(): _apply_normal_strength()

@export var billboard_mode: BaseMaterial3D.BillboardMode = BaseMaterial3D.BillboardMode.BILLBOARD_PARTICLES:
	set(value):
		billboard_mode = value
		if is_node_ready(): _apply_billboard_mode()

@export_group("Rotation Settings")
## Minimum initial rotation in degrees (e.g., -180 for full random)
@export var initial_angle_min: float = 0.0:
	set(value):
		initial_angle_min = value
		if is_node_ready(): _apply_rotation_settings()
## Maximum initial rotation in degrees (e.g., 180 for full random)
@export var initial_angle_max: float = 0.0:
	set(value):
		initial_angle_max = value
		if is_node_ready(): _apply_rotation_settings()
## How fast they spin in degrees per second (e.g., 30.0)
@export var angular_velocity: float = 0.0:
	set(value):
		angular_velocity = value
		if is_node_ready(): _apply_rotation_settings()


@abstract func get_particles() -> CPUParticles3D
@abstract func _ready_implementation() -> void

## can be overriden. runs after all other _ready logic
func _ready_implementation_not_editor() -> void: return


func _ready() -> void:
	if get_particles() and get_particles().material_override:
		get_particles().material_override = get_particles().material_override.duplicate()

	
	_apply_all_properties()
	
	_ready_implementation()

	if not u.is_editor():
		_ready_implementation_not_editor()


func _apply_all_properties() -> void:
	_apply_amount()
	_apply_lifetime()
	_apply_lifetime_randomness()
	_apply_preprocess()
	_apply_scale()
	_apply_emission_extents()
	_apply_color()
	_apply_normal_strength()
	_apply_billboard_mode()
	_apply_rotation_settings()


# region Apply Functions

func _apply_amount() -> void:
	if get_particles(): get_particles().amount = particles_amount

func _apply_lifetime() -> void:
	if get_particles(): get_particles().lifetime = lifetime

func _apply_lifetime_randomness() -> void:
	if get_particles(): get_particles().lifetime_randomness = lifetime_randomness

func _apply_preprocess() -> void:
	if get_particles(): get_particles().preprocess = preprocess

func _apply_scale() -> void:
	if get_particles():
		get_particles().scale_amount_min = particle_scale * 0.95
		get_particles().scale_amount_max = particle_scale * 1.05

func _apply_emission_extents() -> void:
	if get_particles(): get_particles().emission_box_extents = emission_box_extents

func _apply_color() -> void:
	if get_particles(): get_particles().color = color_multiplier

func _apply_normal_strength() -> void:
	var mat := get_particles().material_override if get_particles() else null
	if mat and mat is BaseMaterial3D:
		mat.normal_scale = normal_strength

func _apply_billboard_mode() -> void:
	var mat := get_particles().material_override if get_particles() else null
	if mat and mat is StandardMaterial3D:
		var mat_casted: StandardMaterial3D = mat
		mat_casted.billboard_mode = billboard_mode

func _apply_rotation_settings() -> void:
	if get_particles():
		get_particles().angle_min = initial_angle_min
		get_particles().angle_max = initial_angle_max
		get_particles().angular_velocity_min = angular_velocity
		get_particles().angular_velocity_max = angular_velocity

# endregion


## Stops rendering, Stops emitting, Stops CPU processing (Cost = 0).
func disable():
	set_effect_enabled(false)

func enable():
	set_effect_enabled(true)

func set_effect_enabled(enabled: bool) -> void:
	self.visible = enabled
	
	self.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	
	if get_particles():
		get_particles().emitting = enabled
