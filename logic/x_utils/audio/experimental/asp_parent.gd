class_name SimpleAudioLooper3D
extends Node3DLogger


@export_group("Audio Configuration")
@export var stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var unit_size: float = 5.0
@export var max_distance: float = 20.0
@export var max_polyphony: int = 1
@export var panning_strength: float = 0.5
@export var bus := BusID.GAME_SFX

@export_group("Loop Settings")
@export var loop_enabled: bool = true

## Start time in seconds (where the loop begins)
@export var loop_start_time: float = 0.0
## End time in seconds. If set to 0.0, it uses the full stream length
@export var loop_end_time: float = 0.0
## Duration of the Fade In (at start) and Fade Out (at end)
@export var fade_duration: float = 1.0


var _asp: AudioStreamPlayer3D
var _loop_tween: Tween


func _ready() -> void:
	_create_asp()
	_apply_config()
	
	if loop_enabled:
		_start_loop_sequence()
	else:
		_asp.play()


func _create_asp() -> void:
	_asp = AudioStreamPlayer3D.new()
	add_child(_asp)


func _apply_config() -> void:
	_asp.stream = stream
	_asp.unit_size = unit_size
	_asp.max_distance = max_distance
	_asp.max_polyphony = max_polyphony
	_asp.panning_strength = panning_strength
	_asp.bus = bus
	_asp.pitch_scale = pitch_scale
	_asp.volume_db = volume_db


func _start_loop_sequence() -> void:
	if not stream:
		return
		
	# Determine actual end time
	var valid_end_time := loop_end_time
	if valid_end_time <= 0.01:
		valid_end_time = stream.get_length()
		
	var play_duration := valid_end_time - loop_start_time
	
	if play_duration <= 0.0:
		__log_error("SimpleAudioLooper3D: Loop duration is <= 0. check start/end times.")
		return

	# safe fade times to prevent overlapping if clip is super short
	# e.g. duration 1.0s and fade 1.0s -> fade both in/out for 0.5s
	var effective_fade_in := minf(fade_duration, play_duration / 2.0)
	var effective_fade_out := minf(fade_duration, play_duration / 2.0)
	var sustain_time := play_duration - effective_fade_in - effective_fade_out

	# reset asp state
	_asp.stop()
	_asp.seek(loop_start_time)
	_asp.volume_db = -80.0 # Start silent
	_asp.play()
	
	if _loop_tween:
		_loop_tween.kill()
	_loop_tween = create_tween()
	
	# fade in
	_loop_tween.tween_property(_asp, PropC.VOLUME_DB, volume_db, effective_fade_in)
	
	# middle
	if sustain_time > 0:
		_loop_tween.tween_interval(sustain_time)
		
	# fade out
	_loop_tween.tween_property(_asp, PropC.VOLUME_DB, -80.0, effective_fade_out)
	
	# restart Loop
	_loop_tween.tween_callback(_start_loop_sequence)


## stop
func stop_audio() -> void:
	if _loop_tween: _loop_tween.kill()
	_asp.stop()


## restarts/play manually (ignores loop setting, plays once)
func play_once() -> void:
	if _loop_tween: _loop_tween.kill()
	_asp.stop()
	_apply_config() # Reset volume_db to normal
	_asp.seek(loop_start_time)
	_asp.play()
