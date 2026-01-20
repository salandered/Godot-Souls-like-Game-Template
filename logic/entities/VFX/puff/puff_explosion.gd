@tool
class_name PuffExplosion
extends BaseParticlesEffect

var emit_started: bool = false

@onready var puff_explosion_particles: CPUParticles3D = %PuffExplosionParticles

func get_particles() -> CPUParticles3D:
	return puff_explosion_particles


func _ready_implementation() -> void:
	if emit_started: return
	emit_started = true
	
	get_particles().emitting = true

	if not Engine.is_editor_hint():
		get_particles().finished.connect(queue_free)
