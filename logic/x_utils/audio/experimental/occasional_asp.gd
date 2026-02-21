class_name OccasionalAudioPlayer3D
extends Node3D

@export_group("Audio Configuration")
@export var stream: AudioStream
@export var volume_db: float = 0.0
@export var unit_size: float = 5.0
@export var max_distance: float = 20.0
@export var max_polyphony: int = 1
@export var panning_strength: float = 0.5
@export var bus: = BusID.GAME_SFX

@export_group("Timing Settings")
## Minimum time to wait between plays
@export var min_wait_time: float = 2.0
## Maximum time to wait between plays
@export var max_wait_time: float = 10.0
## If true, waits a random amount before the very first play. 
## If false, plays immediately on ready.
@export var random_start_delay: bool = true

@export_group("Randomization")
## Minimum pitch scale (1.0 is normal)
@export var min_pitch: float = 0.8
## Maximum pitch scale
@export var max_pitch: float = 1.2
## If true, volume also varies slightly
@export var vary_volume: bool = true
## Volume variance lower bound (e.g. -2.0 dB)
@export var min_vol_offset: float = -2.0
## Volume variance upper bound (e.g. 0.0 dB)
@export var max_vol_offset: float = 0.0


var _asp: AudioStreamPlayer3D
var _timer: Timer


func _ready() -> void:
	_create_asp()
	_create_timer()
	_apply_base_config()
	
	if random_start_delay:
		_start_timer()
	else:
		_on_timeout() # Play immediately then start loop


func _create_asp() -> void:
	_asp = AudioStreamPlayer3D.new()
	add_child(_asp)


func _create_timer() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func _apply_base_config() -> void:
	_asp.stream = stream
	_asp.unit_size = unit_size
	_asp.max_distance = max_distance
	_asp.max_polyphony = max_polyphony
	_asp.panning_strength = panning_strength
	_asp.bus = bus


func _start_timer() -> void:
	var wait = randf_range(min_wait_time, max_wait_time)
	_timer.start(wait)


func _on_timeout() -> void:
	if stream:
		_play_randomized()
	
	# Schedule next play
	_start_timer()


func _play_randomized() -> void:
	_asp.pitch_scale = randf_range(min_pitch, max_pitch)
	
	var final_vol = volume_db
	if vary_volume:
		final_vol += randf_range(min_vol_offset, max_vol_offset)
	_asp.volume_db = final_vol
	
	#
	_asp.play()


## Manually force a play (resets the timer loop)
func play_now() -> void:
	_timer.stop()
	_on_timeout()
