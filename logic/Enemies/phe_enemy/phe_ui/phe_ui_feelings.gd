extends Node


@onready var e_feelings: PHEFeelings = %PHEFeelings

@onready var back_health_bar: TextureProgressBar = %BackHealthBar
@onready var health_bar: TextureProgressBar = %HealthBar

## Delayed damage indicator
## shows where health was before damage
@onready var ghost_bar: TextureProgressBar = %GhostBar


## how long the change animation should take
var ANIM_HEALTH_DUR: float = 0.2
var GHOST_HEALTH_DUR: float = 0.8
var GHOST_DELAY: float = 0.5
var PULSE_DURATION: float = 1.0


var _is_pulsing: bool = false

var _health_tween: Tween
var _ghost_tween: Tween
var _pulse_tween: Tween


var _prev_health: float


func _ready() -> void:
	var max_health := e_feelings.get_max_health()
	health_bar.max_value = max_health
	health_bar.value = e_feelings.get_curr_health()
	
	ghost_bar.texture_progress = health_bar.texture_progress # Reuse same texture
	ghost_bar.max_value = max_health
	ghost_bar.value = e_feelings.get_curr_health()
	# ghost_bar.modulate = Color(1, 1, 1, 0.4) # Better in UI
	
	_prev_health = e_feelings.get_curr_health()


func _process(delta: float):
	# polling on every frame - may be switch to signals
	_update_health_bar()


func _update_health_bar():
	var curr_health := e_feelings.get_curr_health()
	if curr_health == _prev_health:
		return

	_animate_health_change(curr_health)
	
	var is_damage := curr_health < _prev_health
		
	if is_damage:
		_animate_ghost_bar_change(_prev_health, curr_health)
	else:
		# instant ghost bar update on heal
		ghost_bar.value = curr_health
	
	if e_feelings.is_lower_phase_switch() and not _is_pulsing:
		_start_low_health_pulse()
	elif not e_feelings.is_lower_phase_switch() and _is_pulsing:
		_stop_low_health_pulse()
	
	_prev_health = curr_health


func _animate_health_change(target_value: float) -> void:
	if _health_tween:
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.tween_property(
		health_bar,
		"value",
		target_value,
		ANIM_HEALTH_DUR
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _animate_ghost_bar_change(from_value: float, to_value: float) -> void:
	if _ghost_tween:
		_ghost_tween.kill()
	
	# ghost to prev health immediately
	ghost_bar.value = from_value
	
	# after delay, drain ghost bar to curr health
	_ghost_tween = create_tween()
	_ghost_tween.tween_interval(GHOST_DELAY)
	_ghost_tween.tween_property(
		ghost_bar,
		"value",
		to_value,
		GHOST_HEALTH_DUR
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _start_low_health_pulse() -> void:
	if _is_pulsing:
		return
	_is_pulsing = true
	
	if _pulse_tween:
		_pulse_tween.kill()
	
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(
		health_bar,
		"modulate:a", # Just alpha channel
		0.5,
		PULSE_DURATION * 0.5
	).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(
		health_bar,
		"modulate:a",
		1.0,
		PULSE_DURATION * 0.5
	).set_trans(Tween.TRANS_SINE)


func _stop_low_health_pulse() -> void:
	_is_pulsing = false
	if _pulse_tween:
		_pulse_tween.kill()
	health_bar.modulate.a = 1.0
