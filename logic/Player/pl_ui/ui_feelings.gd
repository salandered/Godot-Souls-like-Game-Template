extends Node
@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar

@onready var feelings: PlayerFeelings = %Feelings

## How long the health change animation should take, in seconds.
@export var animation_duration_health: float = 0.2
@export var animation_duration_stamina: float = 0.5

var _max_health: int
var _health_tween: Tween

var _max_stamina: int
var _stamina_tween: Tween


func _ready() -> void:
	_max_health = feelings.max_health
	health_bar.max_value = _max_health
	health_bar.value = _max_health
	
	_max_stamina = feelings.max_stamina
	stamina_bar.max_value = _max_stamina
	stamina_bar.value = _max_stamina

func _on_feelings_sig_health_changed(new_health: int) -> void:
	_animate_health_change(new_health)

func _on_feelings_sig_stamina_changed(new_stamina: int) -> void:
	_animate_stamina_change(new_stamina)


# Private helper function to handle the tweening logic.
func _animate_health_change(target_value: int) -> void:
	# If a previous animation is running, stop it immediately.
	if _health_tween:
		_health_tween.kill()
	
	# Create a new tween to animate from the current value to the target value.
	_health_tween = create_tween()
	_health_tween.tween_property(
		health_bar, 
		"value", 
		target_value, 
		animation_duration_health
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func _animate_stamina_change(target_value: int) -> void:
	# If a previous animation is running, stop it immediately.
	if _stamina_tween:
		_stamina_tween.kill()
	
	# Create a new tween to animate from the current value to the target value.
	_stamina_tween = create_tween()
	_stamina_tween.tween_property(
		stamina_bar, 
		"value", 
		target_value, 
		animation_duration_stamina
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
