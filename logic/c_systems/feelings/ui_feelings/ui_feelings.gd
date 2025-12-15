extends Node
@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar

@onready var pl_feelings: PlayerFeelings = %Feelings

## How long the change animation should take, in seconds
var ANIM_DURATION_HEALTH: float = 0.2
var ANIM_DURATION_STAMINA_HIT: float = 0.2 # fancy tween
var ANIM_DURATION_STAMINA_REGEN: float = 0.1 # fast tween
##
const STAMINA_LERP_SPEED = 10.0
##
const STAMINA_BIG_CHANGE_THRESHOLD = 3.0

##
var _health_tween: Tween
var _stamina_tween: Tween
var _stamina_flash_tween: Tween

var _prev_health: float
var _prev_stamina: float


func _ready() -> void:
	health_bar.max_value = pl_feelings.get_max_health()
	health_bar.value = pl_feelings.get_curr_health()
	_prev_health = pl_feelings.get_curr_health()
	
	stamina_bar.max_value = pl_feelings.max_stamina
	stamina_bar.value = pl_feelings.get_curr_stamina()
	_prev_stamina = pl_feelings.get_curr_stamina()

	pl_feelings.SIG_cant_be_paid.connect(_animate_stamina_flash)


func _process(delta: float) -> void:
	_update_health_bar()
	_update_stamina_bar(delta)


func _update_health_bar():
	var current_health := pl_feelings.get_curr_health()
	if current_health == _prev_health:
		return

	_animate_health_change(current_health)
	_prev_health = current_health


func _update_stamina_bar(delta: float):
	var current_stamina := pl_feelings.get_curr_stamina()
	if current_stamina == _prev_stamina:
		return

	var change_amount := absf(current_stamina - _prev_stamina)
	
	if change_amount > STAMINA_BIG_CHANGE_THRESHOLD:
		_animate_stamina_change(current_stamina)
	else:
		# stamina_bar.value = current_stamina
		stamina_bar.value = lerp(stamina_bar.value, current_stamina, STAMINA_LERP_SPEED * delta)
	
	if pl_feelings.is_in_fatigue():
		stamina_bar.modulate = Color(1.077, 0.711, 0.412, 1.0)
	else:
		stamina_bar.modulate = Color(1, 1, 1)
	_prev_stamina = current_stamina


func _animate_stamina_flash():
	pass
	# if _stamina_flash_tween:
	# 	_stamina_flash_tween.kill()
	# _stamina_flash_tween = create_tween()
	# _stamina_flash_tween.set_loops(3)
	# _stamina_flash_tween.tween_property(stamina_bar, "modulate", Color(1.8, 1.8, 1.8), 0.15)
	# _stamina_flash_tween.tween_property(stamina_bar, "modulate", Color(1, 1, 1), 0.15)

	
func _animate_health_change(target_value: float) -> void:
	UIUtils.kill_tween_if_exists(_health_tween)
	
	_health_tween = UIUtils.animate_property(
		self,
		health_bar,
		"value",
		target_value,
		ANIM_DURATION_HEALTH
	)
	
	
func _animate_stamina_change(target_value: float) -> void:
	UIUtils.kill_tween_if_exists(_stamina_tween)
	
	_stamina_tween = UIUtils.animate_property(
		self,
		stamina_bar,
		"value",
		target_value,
		ANIM_DURATION_STAMINA_HIT
	)