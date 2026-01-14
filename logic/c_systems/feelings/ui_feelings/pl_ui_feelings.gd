class_name PlUIFeelings
extends NodeSystem

@onready var _health_bar: TextureProgressBar = %HealthBar
@onready var _health_ghost: TextureProgressBar = %GhostHealthBar
@onready var _health_back: TextureProgressBar = %BackHealthBar
@onready var _health_container: MarginContainer = %HealthContainer

@onready var _stamina_bar: TextureProgressBar = %StaminaBar
@onready var _stamina_ghost: TextureProgressBar = %GhostStaminaBar
@onready var _stamina_back: TextureProgressBar = %BackStaminaBar
@onready var _stamina_container: MarginContainer = %StaminaContainer

@onready var pl_feelings: PlayerFeelings = %Feelings


var STAMINA_BIG_CHANGE_THRESHOLD := 3.0
var STAMINA_LERP_SPEED := 10.0

var health_bar: FeelingBar
var stamina_bar: FeelingBar

var _prev_health: float
var _prev_stamina: float
var _pixels_per_stamina: float
var _size_tween: Tween


func __hard_dependencies() -> Array[Object]:
	return [
		_health_bar,
		_health_container,
		_stamina_bar,
		_stamina_container,
		pl_feelings

	]

func __soft_dependencies() -> Array[Object]:
	return [
		_health_ghost,
		_health_back,
		_stamina_ghost,
		_stamina_back
	]


func _ready() -> void:
	_setup_feeling_bars()

	GlobalSignal.player_max_health_increase.connect_(_on_player_increase_max_health)
	GlobalSignal.player_max_stamina_increase.connect_(_on_player_increase_max_stamina)
	# pl_feelings.SIG_cant_be_paid.connect(_animate_stamina_flash)

	__perform_validation()

	# get_tree().create_timer(1.0).timeout.connect(func():
	# 	__log_("\n========= DEBUG BAR STATE =========")
	# 	__log_("Feelings Max Stamina: ", pl_feelings.max_stamina)
	# 	__log_("Feelings Curr Stamina: ", pl_feelings.get_curr_stamina())
	
	# )

func _setup_feeling_bars() -> void:
	if pl_feelings:
		var health_conf := FeelingBarConfig.new(
			0.2, 0.8, 0.5, 1.0,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		health_bar = FeelingBar.new(
			_health_bar,
			_health_ghost,
			_health_back,
			_health_container,
			pl_feelings.get_curr_health(),
			pl_feelings.get_max_health(),
			health_conf,
			"PlHealth"
		)
		_prev_health = pl_feelings.get_curr_health()


		var stamina_conf := FeelingBarConfig.new(
					0.2, 0.8, 0.5, 1.0,
					Tween.TRANS_EXPO,
					Tween.EASE_OUT
				)
		stamina_bar = FeelingBar.new(
			_stamina_bar,
			_stamina_ghost,
			_stamina_back,
			_stamina_container,
			pl_feelings.get_curr_stamina(),
			pl_feelings.max_stamina,
			stamina_conf,
			"PlStamina"
		)
		_prev_stamina = pl_feelings.get_curr_stamina()


func _process(delta: float) -> void:
	if not __validation_ok():
		return
	_update_health_bar()
	_update_stamina_bar(delta)


func _update_health_bar() -> void:
	var curr_health := pl_feelings.get_curr_health()
	if curr_health == _prev_health:
		return

	health_bar.animate_main_bar_value_change(self, curr_health)
	
	# Ghost bar logic
	var is_damage := curr_health < _prev_health
	if is_damage:
		health_bar.animate_ghost_bar_value_change(self, _prev_health, curr_health)
	else:
		health_bar.set_ghost_bar_value(curr_health)
		
	_prev_health = curr_health


func _update_stamina_bar(delta: float) -> void:
	var curr_stamina := pl_feelings.get_curr_stamina()
	var ui_val := stamina_bar.get_main_bar_value()
	
	var logic_changed := curr_stamina != _prev_stamina
	var ui_desynced := not is_equal_approx(ui_val, curr_stamina)

	if not logic_changed and not ui_desynced:
		return
	
	if not logic_changed and ui_desynced:
		__log_("stamina_sync", "Catching up. Logic:", curr_stamina, "UI:", ui_val)

	# if curr_stamina == _prev_stamina:
	# 	return

	var change_amount := absf(curr_stamina - _prev_stamina)

	# big hit
	if change_amount > STAMINA_BIG_CHANGE_THRESHOLD:
		__log_("_update_stamina_bar", "big hit. change_amount/STAMINA_BIG_CHANGE_THRESHOLD",
			str(change_amount), STAMINA_BIG_CHANGE_THRESHOLD)

		stamina_bar.animate_main_bar_value_change(self, curr_stamina)
		
		# only animate ghost on drop, snap on regen
		if curr_stamina < _prev_stamina:
			stamina_bar.animate_ghost_bar_value_change(self, _prev_stamina, curr_stamina)
		else:
			stamina_bar.set_ghost_bar_value(curr_stamina)
	# small change
	else:
		# if main bar is currently being animated by a Tween (e.g. from a recent big hit),
		# do not lerp it, let the Tween finish.
		if stamina_bar.is_main_animating():
			# We update _prev_stamina so we don't trigger "Big Hit" again next frame
			_prev_stamina = curr_stamina
			return
		var new_val := lerpf(ui_val, curr_stamina, STAMINA_LERP_SPEED * delta)
		
		# Snap to target if very close to avoid infinite visual lag
		if abs(new_val - curr_stamina) < 0.1:
			new_val = curr_stamina
			
		stamina_bar.set_main_bar_value(new_val)
		
		# Don't interrupt the Ghost Bar if it's waiting/animating a big hit
		if not stamina_bar.is_ghost_animating():
			stamina_bar.set_ghost_bar_value(new_val)

	_handle_stamina_color()
	_prev_stamina = curr_stamina


func _handle_stamina_color() -> void:
	if pl_feelings.is_in_fatigue():
		stamina_bar.main_bar_modulate(Color(1.077, 0.711, 0.412, 1.0))
	else:
		stamina_bar.main_bar_modulate_reset()


func _on_player_increase_max_health(payload: Dictionary) -> void:
	var _r := SigUtils.safe_get_int_float_payload_value(payload, GlobalSignal.payload_amount_field)
	if _r.err:
		return
	__log_("_on_player_increase_max_health", "triggered with value", _r.value)
	
	health_bar.animate_bar_size_increase(_r.value)


func _on_player_increase_max_stamina(payload: Dictionary) -> void:
	var _r := SigUtils.safe_get_int_float_payload_value(payload, GlobalSignal.payload_amount_field)
	if _r.err:
		return
	__log_("_on_player_increase_max_stamina", "triggered with value", _r.value)
	
	stamina_bar.animate_bar_size_increase(_r.value)
	
	
func __LOG_B() -> bool:
	return LogToggler.FEEL.PL_UI