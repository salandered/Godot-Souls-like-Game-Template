@tool
class_name PlayerFeelings
extends BaseFeelings


var FATIGUE_STATUS := "FATIGUE〰️"

const FATIGUE_THRESHOLD = 8.0
var max_stamina: float = 170.0
var max_health: float = 220.0

var stamina_regen_rate: float = 16.0 # per sec

var _current_stamina: float

# signal SIG_cant_be_paid

var ZERO_DRAIN_TIME := 0.8
var zero_drain_timer := DelayCallbackTimer.new()
## blocks any stamina changes
var IN_ZERO_DRAIN: bool = false


var regen_delay_timer := DelayCallbackTimer.new()
var REGEN_DELAY_TIME := 0.5


func initialise() -> void:
	_current_stamina = max_stamina
	
	statuses = {
		FATIGUE_STATUS: false
	}

	if __perform_validation(true):
		GlobalSignal.player_change_health.connect_(_on_player_change_health)
		GlobalSignal.player_max_health_increase.connect_(_on_player_max_health_increase)
		GlobalSignal.player_max_stamina_increase.connect_(_on_player_max_stamina_increase)

		Console.add_command("god", _on_console_god, ["true_false"], 0, "by default is true")
		Console.add_command("health_set", _on_console_set_health, ["amount"], 1)
		Console.add_command("health_max_increase", _on_console_health_max_increase, ["amount"], 1, )
		Console.add_command("stamina_max_increase", _on_console_stamina_max_increase, ["amount"], 1, )


func is_player() -> bool:
	return true


func get_max_health() -> float:
	return max_health


func lose_stamina(amount: float):
	_change_stamina(-amount)
	if amount != 0.0:
		regen_delay_timer.initialise(REGEN_DELAY_TIME, _on_regen_delay_ended)


func add_stamina(amount: float):
	_change_stamina(amount)


func can_allow_stamina_drain(amount: float) -> bool:
	return can_allow_stamina_rate(-amount)


func get_curr_stamina() -> float:
	return _current_stamina


func _process(delta: float) -> void:
	if zero_drain_timer.is_in_progress():
		zero_drain_timer.update(delta)
	if regen_delay_timer.is_in_progress():
		regen_delay_timer.update(delta)


## being called from character SM _process
func _update(delta: float, stamina_drain: float = 0.0):
	update(delta, -stamina_drain)


## requested_stamina_rate is negative if it's a drain
## (positive for gain)
func update(delta: float, requested_stamina_rate: float = 0.0):
	## requested_stamina_rate overrides stamina_regen_rate
	if not IN_ZERO_DRAIN:
		var result_rate := stamina_regen_rate

		if regen_delay_timer.is_in_progress():
			result_rate = 0.0

		if requested_stamina_rate != 0.0:
			result_rate = requested_stamina_rate
		# __log_("update", "result/stamina_regen/requested rates", result_rate, stamina_regen_rate, requested_stamina_rate)
		_change_stamina(result_rate * delta, true)


func _change_stamina(amount: float, is_rate: bool = false) -> void:
	if amount == 0.0: return
	if __god_mode:
		return
	
	if IN_ZERO_DRAIN: return

	var _new_stamina := _current_stamina + amount
	_current_stamina = clampf(_new_stamina, 0.0, max_stamina)

	if _current_stamina <= 0.0:
		_trigger_reach_zero()

	if is_in_fatigue() and _current_stamina > FATIGUE_THRESHOLD:
		statuses[FATIGUE_STATUS] = false
		__log_("stamina", pp.s("erase status", FATIGUE_STATUS))

	if abs(amount) > 1: __log_("stamina", pp.s("changed", amount))


func change_stamina_regen_rate(amount: float) -> void:
	var _new_stamina_regen_rate := stamina_regen_rate + amount
	stamina_regen_rate = clampf(_new_stamina_regen_rate, 0.0, 100)
	__log_("stamina regen rate", pp.s("changed", amount))


func is_in_fatigue() -> bool:
	return check_status(FATIGUE_STATUS)


func stamina_can_be_paid(amount: float) -> bool:
	var decision: bool = false
	var _reason: String = ""
	if amount < 0:
		_reason = "amount is negative, it's strange"
		decision = true
	## 0.0 is always allowed
	elif amount == 0.0:
		decision = true
	## fatigue blocks all 'demanding' requests
	elif is_in_fatigue() and amount > 0:
		decision = false
	# below without statuses with positive amount
	## if _current_stamina has even a little value, we go for it
	elif _current_stamina > 0:
		decision = true
	
	# if decision == false:
		# SIG_cant_be_paid.emit()
	
	__log_feel_check_stamina("stamina_can_be_paid", amount, decision, _reason)
	return decision


func can_allow_stamina_rate(stamina_rate: float = 0.0) -> bool:
	var decision: bool = false
	var _reason: String = ""
	
	if stamina_rate >= 0.0: ## zero and gain is always allowed
		decision = true
	elif is_in_fatigue():
		decision = false
	else: ## no statuses and stamina_rate is drain. that's ok
		decision = true
		
	# if decision == false:
		# SIG_cant_be_paid.emit()
	
	__log_feel_check_stamina("can_allow_stamina_rate", stamina_rate, decision, _reason)
	return decision


# region: ZERO DRAIN

func _on_zero_drain_ended() -> void:
	IN_ZERO_DRAIN = false
	if _current_stamina <= 0.0:
		_current_stamina += 0.5 # give it a little bump just to be safe
	__log_("stamina", "zero_drain ended, stamina bumped to" + str(_current_stamina))


## if zero reached, we spent some time ignoring changes.
## zero timer and setting fatigue should be atomic operation.
func _trigger_reach_zero() -> void:
	if IN_ZERO_DRAIN: return # already was triggered
	
	statuses[FATIGUE_STATUS] = true
	zero_drain_timer.initialise(ZERO_DRAIN_TIME, _on_zero_drain_ended)
	IN_ZERO_DRAIN = true
	__log_("stamina", pp.s("set status", FATIGUE_STATUS, "and triggered zero_drain_timer with", ZERO_DRAIN_TIME))

# endregion

func _on_regen_delay_ended() -> void:
	pass


##


func _on_player_change_health(payload: Dictionary[StringName, Variant]) -> void:
	var _r := SigUtils.safe_get_int_float_payload_value(payload, SPS.amount_field)
	if _r.err:
		return
	__log_("_on_player_change_health", "triggered with value", _r.value)
	_change_health(_r.value)
	
func _on_player_max_health_increase(payload: Dictionary[StringName, Variant]) -> void:
	var _r := SigUtils.safe_get_int_float_payload_value(payload, SPS.amount_field)
	if _r.err:
		return
	__log_("_on_player_max_health_increase", "triggered with value", _r.value)
	max_health += _r.value

func _on_player_max_stamina_increase(payload: Dictionary[StringName, Variant]) -> void:
	var _r := SigUtils.safe_get_int_float_payload_value(payload, SPS.amount_field)
	if _r.err:
		return
	__log_("_on_player_max_stamina_increase", "triggered with value", _r.value)
	max_stamina += _r.value
	

##


func __log_feel_check_stamina(prefix: String, amount: float, decision: bool, ...context: Array):
	if decision == true: return
	var _msg := pp.s("currStamina", _current_stamina, "requested", amount, "statuses", pp.dict_(statuses, false, true))
	__log_(prefix, _msg, " ", pp.list_(context) + "=>", decision)


func _on_console_god(true_false_param: String):
	print_.console("_on_console_god", "true_false_param", true_false_param)
	match true_false_param:
		"":
			set_god_mode(true)
		"true":
			set_god_mode(true)
		"false":
			set_god_mode(false)
		_:
			print_.console("unknown console command")
		

func _on_console_set_health(amount: String):
	print_.console("_on_console_set_health", "amount", amount)
	__set_specific_health(amount.to_float())
		
func _on_console_health_max_increase(amount: String):
	print_.console("_on_console_health_max_increase", "amount", amount)
	var signal_data := GlobalSignal.player_max_health_increase
	SigUtils.safe_emit_sig_data(signal_data, {SPS.amount_field: amount.to_float()}, false)


func _on_console_stamina_max_increase(amount: String):
	print_.console("_on_console_stamina_max_increase", "amount", amount)
	var signal_data := GlobalSignal.player_max_stamina_increase
	SigUtils.safe_emit_sig_data(signal_data, {SPS.amount_field: amount.to_float()}, false)
		

func set_god_mode(enable: bool):
	__god_mode = enable
	if enable:
		_current_stamina = max_stamina
		_current_health = max_health


##


func __LOG_B() -> bool:
	return false # LogToggler.FEEL.PL
