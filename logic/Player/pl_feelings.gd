@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_heart.png")
extends Node
class_name PlayerFeelings

var statuses: Dictionary # todo: system
var FATIGUE_STATUS = "FATIGUE〰️"

var __god_mode: bool = true

const FATIGUE_THRESHOLD = 5.0
const max_health: float = 60.0
const max_stamina: float = 60.0

var stamina_regen_rate: float = 5.0 # per sec

var _current_health: float
var _current_stamina: float

signal SIG_cant_be_paid

var ZERO_DRAIN_TIME := 0.8
var zero_drain_timer := DelayCallbackTimer.new()
## blocks any stamina changes
var IN_ZERO_DRAIN: bool = false


func _ready() -> void:
	_current_health = max_health
	_current_stamina = max_stamina
	
	statuses = {
		FATIGUE_STATUS: false
	}


func _process(delta: float) -> void:
	if zero_drain_timer.is_in_progress():
		zero_drain_timer.update(delta)


# region: SHORTCUTS FOR PSM

func pay_state_cost(amount: float):
	_change_stamina(-amount)

func add_health(amount: float):
	_change_health(amount)

func lose_health(amount: float):
	_change_health(-amount)

func add_stamina(amount: float):
	_change_stamina(amount)

func lose_stamina(amount: float):
	_change_stamina(-amount)

func can_allow_stamina_drain(amount: float) -> bool:
	return can_allow_stamina_rate(-amount)

func is_zero_health() -> bool:
	return _current_health <= 0

# endregion


## called from Player SM
func _update(delta: float, stamina_drain: float = 0.0):
	update(delta, -stamina_drain)

## requested_stamina_rate is negative if it's a drain
## (positive for gain)
func update(delta: float, requested_stamina_rate: float = 0.0):
	## requested_stamina_rate overrides stamina_regen_rate
	if not IN_ZERO_DRAIN:
		var result_rate = stamina_regen_rate
		if requested_stamina_rate != 0.0:
			result_rate = requested_stamina_rate
		_change_stamina(result_rate * delta)


func get_current_health() -> float:
	return _current_health

func get_current_stamina() -> float:
	return _current_stamina


func _change_health(amount: float) -> void:
	if amount == 0.0: return
	if __god_mode:
		if abs(amount) > 1: print_.feel("health", pp.s("not changed: god mode"))
		return

	var _new_health := _current_health + amount
	_current_health = clampf(_new_health, 0, max_health)
	
	# TODO if _current_health <= 0.0:
	
	if abs(amount) > 1: print_.feel("health", pp.s("changed", amount))


func _change_stamina(amount: float) -> void:
	if amount == 0.0: return
	if __god_mode:
		if abs(amount) > 1: print_.feel("health", pp.s("not changed: god mode"))
		return
	
	if IN_ZERO_DRAIN: return

	var _new_stamina := _current_stamina + amount
	_current_stamina = clampf(_new_stamina, 0.0, max_stamina)

	if _current_stamina <= 0.0:
		_trigger_reach_zero()

	if is_in_fatigue() and _current_stamina > FATIGUE_THRESHOLD:
		statuses[FATIGUE_STATUS] = false
		print_.feel("stamina", pp.s("erase status", FATIGUE_STATUS))

	if abs(amount) > 1: print_.feel("stamina", pp.s("changed", amount))


func change_stamina_regen_rate(amount: float) -> void:
	var _new_stamina_regen_rate := stamina_regen_rate + amount
	stamina_regen_rate = clampf(_new_stamina_regen_rate, 0.0, 100)
	print_.feel("stamina regen rate", pp.s("changed", amount))


func is_in_fatigue() -> bool:
	return statuses[FATIGUE_STATUS]


func can_be_paid(amount: float) -> bool:
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
	
	if decision == false:
		SIG_cant_be_paid.emit()
	
	__log_feel_check_stamina("can_be_paid", amount, decision, _reason)
	return decision


func can_allow_stamina_rate(stamina_rate: float = 0.0) -> bool:
	var decision: bool = false
	var _reason: String = ""
	
	if stamina_rate >= 0.0: ## gain is always allowed
		decision = true
	elif is_in_fatigue():
		decision = false
	else: ## no statuses and stamina_rate is drain. that's ok
		decision = true
		
	if decision == false:
		SIG_cant_be_paid.emit()
	
	__log_feel_check_stamina("can_allow_stamina_rate", stamina_rate, decision, _reason)
	return decision


# region: ZERO DRAIN

func _on_zero_drain_ended():
	IN_ZERO_DRAIN = false
	if _current_stamina <= 0.0:
		_current_stamina += 0.5 # give it a little bump just to be safe
	print_.feel("stamina", "zero_drain ended, stamina bumped to" + str(_current_stamina))


## if zero reached, we spent some time ignoring changes
## zero timer and setting fatigue should be atomic operation.
func _trigger_reach_zero():
	if IN_ZERO_DRAIN: return # already was triggered
	
	statuses[FATIGUE_STATUS] = true
	zero_drain_timer.initialise(ZERO_DRAIN_TIME, _on_zero_drain_ended)
	IN_ZERO_DRAIN = true
	print_.feel("stamina", pp.s("set status", FATIGUE_STATUS, "and triggered zero_drain_timer with", ZERO_DRAIN_TIME))

# endregion


func __log_feel_check_stamina(prefix, amount, decision, ...context: Array):
	if decision == true: return
	var _msg = pp.s("currStamina", _current_stamina, "requested", amount, "statuses", pp._dict(statuses, false, true))
	print_.feel(prefix, pp.s(_msg, " ", pp.list_(context) + "=>", decision))


# region: DEV

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("t1"):
		add_health(10)
		add_stamina(15)

	if event.is_action_pressed("t2"):
		lose_health(10)
		lose_stamina(15)


# LATER
# func lose_health(amount: float):
# 	if not __god_mode:
# 		health -= amount
# 		if health < 1:
# 			model.current_state.try_force_state(PS.death)


# func pay_block_cost(damage: float, blocking_coefficient: float):
# 	if damage * blocking_coefficient <= stamina:
# 		lose_stamina(damage * blocking_coefficient)
# 	else:
# 		var unblocked_portion := damage - stamina / blocking_coefficient
# 		lose_stamina(stamina)
# 		lose_health(unblocked_portion)
# 		# something punish like force guardbreak 
# 		print("was guardbroken")


# endregion
