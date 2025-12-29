extends NodeLogger


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


var _pixels_per_stamina: float
var _size_tween: Tween

func _ready() -> void:
	health_bar.max_value = pl_feelings.get_max_health()
	health_bar.value = pl_feelings.get_curr_health()
	_prev_health = pl_feelings.get_curr_health()
	
	stamina_bar.max_value = pl_feelings.max_stamina
	stamina_bar.value = pl_feelings.get_curr_stamina()
	_prev_stamina = pl_feelings.get_curr_stamina()

	var current_visual_width = stamina_bar.custom_minimum_size.x
	if current_visual_width == 0:
		current_visual_width = stamina_bar.size.x
	
	if pl_feelings.max_stamina > 0:
		_pixels_per_stamina = current_visual_width / pl_feelings.max_stamina
	else:
		_pixels_per_stamina = 3.0 # Fallback
	
	stamina_bar.custom_minimum_size.x = current_visual_width

	GlobalSignal.player_stamina_increase.connect_(_on_player_increase_stamina)
	# pl_feelings.SIG_cant_be_paid.connect(_animate_stamina_flash)


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


func _on_player_increase_stamina(payload: Dictionary) -> void:
	var value = payload.get(GlobalSignal.payload_amount_field)
	if value and (value is float or value is int):
		var new_max_stamina = stamina_bar.max_value + value
		var new_width = new_max_stamina * _pixels_per_stamina
		var current_height = stamina_bar.custom_minimum_size.y
		
		stamina_bar.max_value = new_max_stamina
		
		UIUtils.kill_tween_if_exists(_size_tween)
		
		_size_tween = create_tween()
		_size_tween.tween_property(
			stamina_bar,
			"custom_minimum_size",
			Vector2(new_width, current_height),
			0.3
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
