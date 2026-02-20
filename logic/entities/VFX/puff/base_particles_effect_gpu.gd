@tool
@icon("res://-assets-/x_icons/red/icon_particle.png")
@abstract
class_name BaseParticlesEffectGPU
extends Node3DLogger


@export var particles_amount: int = 10:
	set(value):
		particles_amount = value
		if is_node_ready(): _apply_amount()

@export var lifetime: float = 9.0:
	set(value):
		lifetime = value
		if is_node_ready(): _apply_lifetime()


@export var preprocess: float = 0.0:
	set(value):
		preprocess = value
		if is_node_ready(): _apply_preprocess()


## takes effect only if particles use normal texture
@export var normal_strength: float = 12.0:
	set(value):
		normal_strength = value
		if is_node_ready(): _apply_normal_strength()

@export var billboard_mode: BaseMaterial3D.BillboardMode = BaseMaterial3D.BillboardMode.BILLBOARD_PARTICLES:
	set(value):
		billboard_mode = value
		if is_node_ready(): _apply_billboard_mode()


@abstract func get_particles() -> GPUParticles3D
@abstract func _ready_implementation() -> void

## can be overriden. runs after all other _ready logic
func _ready_implementation_not_editor() -> void: return


func _ready() -> void:
	if get_particles() and get_particles().material_override:
		get_particles().material_override = get_particles().material_override.duplicate()

	
	#_apply_all_properties()
	
	_ready_implementation()

	if not u.is_editor():
		_ready_implementation_not_editor()


func _apply_all_properties() -> void:
	_apply_amount()
	_apply_lifetime()
	_apply_preprocess()
	_apply_normal_strength()
	_apply_billboard_mode()


# region Apply Functions

func _apply_amount() -> void:
	if get_particles(): get_particles().amount = particles_amount

func _apply_lifetime() -> void:
	if get_particles(): get_particles().lifetime = lifetime


func _apply_preprocess() -> void:
	if get_particles(): get_particles().preprocess = preprocess


func _apply_normal_strength() -> void:
	var mat := get_particles().material_override if get_particles() else null
	if mat and mat is BaseMaterial3D:
		mat.normal_scale = normal_strength

func _apply_billboard_mode() -> void:
	var mat := get_particles().material_override if get_particles() else null
	if mat and mat is StandardMaterial3D:
		var mat_casted: StandardMaterial3D = mat
		mat_casted.billboard_mode = billboard_mode

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
