extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func _ready():
	gpu_particles_3d.emitting = true
	# Auto-cleanup when done
	await get_tree().create_timer(gpu_particles_3d.lifetime + 0.2).timeout
	queue_free()


func set_direction(normal: Vector3):
	var mat = gpu_particles_3d.process_material as ParticleProcessMaterial
	mat.direction = normal
