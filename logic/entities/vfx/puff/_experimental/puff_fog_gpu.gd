@tool
class_name PuffFogGPU
extends BaseParticlesEffectGPU

@onready var test_visuals: Node3D = %test_visuals

@onready var puff_fog_particles: GPUParticles3D = %PuffFogParticles


func get_particles() -> GPUParticles3D:
	return puff_fog_particles


func _ready_implementation() -> void:
	get_particles().emitting = true
	#get_particles().local_coords = true


func _ready_implementation_not_editor() -> void:
	test_visuals.visible = false
