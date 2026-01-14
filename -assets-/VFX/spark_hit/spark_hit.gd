class_name SparksHit
extends Node3DLogger


@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

@export var particles_amount: int = 8:
	set(value):
		particles_amount = value
		if is_node_ready(): _apply_amount()
@export var lifetime: float = 0.3:
	set(value):
		lifetime = value
		if is_node_ready(): _apply_lifetime()
		
		
func _ready():
	gpu_particles_3d.emitting = true
	# Auto-cleanup when done
	_apply_all_properties()
	await get_tree().create_timer(gpu_particles_3d.lifetime + 0.4).timeout
	queue_free()


func _apply_all_properties() -> void:
	_apply_lifetime()
	_apply_amount()


func set_direction(normal: Vector3):
	var mat := gpu_particles_3d.process_material
	if mat is ParticleProcessMaterial:
		mat.direction = normal
	else:
		__log_warn_soft("mat is not ParticleProcessMaterial", "", "return", mat)


func set_from_config(config: ParticlesConfig):
	config.set_up_particles(get_particles())


func get_particles() -> GPUParticles3D:
	return gpu_particles_3d


# region Apply Functions

func _apply_amount() -> void:
	if get_particles(): get_particles().amount = particles_amount

func _apply_lifetime() -> void:
	if get_particles(): get_particles().lifetime = lifetime
