@tool
class_name FireStatic
extends FlickerOmni


@onready var test_visual_fire: MeshInstance3D = $Effect/test_visual_fire


@export_group("Particle Settings")
@export var particles_amount: int = 10:
	set(value):
		particles_amount = value
		if is_node_ready(): _apply_amount()

@export var lifetime: float = 1.0:
	set(value):
		lifetime = value
		if is_node_ready(): _apply_lifetime()

@export var particles_speed_scale: float = 0.5:
	set(value):
		particles_speed_scale = value
		if is_node_ready(): _apply_particles_speed_scale()


@export_group("Sound Settings")
@export var audio_stream: AudioStream = null
@export var play_sound: bool = true:
	set(value):
		play_sound = value
		if is_node_ready(): _apply_sound_settings()


@onready var flame_gpu_particles_3d: GPUParticles3D = %FlameGPUParticles3D


func _ready_implementation() -> void:
	test_visual_fire.visible = false
	super._ready_implementation()

	_apply_sound_settings()

	_apply_amount()
	_apply_lifetime()
	_apply_particles_speed_scale()


func get_particles() -> GPUParticles3D:
	return flame_gpu_particles_3d


func _apply_sound_settings():
	var asps := get_descendants.audio_stream_players_3D(self )
	if len(asps) >= 1:
		var _asp := asps[0]
		if play_sound and audio_stream:
			var asp_config := ASP3DConfig.new(-0.5, -0.37, 3.0, 12, 2, 0.5, BusID.GAME_SFX, audio_stream)
			asp_config.set_up_asp(_asp)
			_asp.play()
		else:
			_asp.stop()


func _apply_amount() -> void:
	if get_particles(): get_particles().amount = particles_amount

func _apply_lifetime() -> void:
	if get_particles(): get_particles().lifetime = lifetime

func _apply_particles_speed_scale() -> void:
	if get_particles(): get_particles().speed_scale = particles_speed_scale
