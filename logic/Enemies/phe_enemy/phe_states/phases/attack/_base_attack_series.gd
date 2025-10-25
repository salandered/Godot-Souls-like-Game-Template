extends BasePHEState
class_name BasePHEAttackSeries


var _attacks_to_do: int


## To assign
var attack_to_number: Dictionary

var MIN_ATTACKS_TO_DO: int = 1
var MAX_ATTACKS_TO_DO: int = 1


func is_ended() -> bool:
	return _is_ended()

func _is_ended() -> bool:
	var _r: bool = true # safer to assume its true by default
	
	# hard stop if player is far way and we ended current attack
	if distance_to_player() > 8 and get_current_substate().time_remaining() < 0.15:
		_r = true
	# in the middle of curr attack
	elif get_current_substate().time_remaining() > 0.15:
		_r = false
	# have more attacks to do
	elif _attacks_to_do >= 1:
		_r = false
	
	if _r == true:
		print_.prefix_s(em.pin, '_is_ended', _attacks_to_do, get_current_substate().time_remaining(), distance_to_player())
	
	return _r


func on_enter_state():
	_attacks_to_do = randi_range(MIN_ATTACKS_TO_DO, MAX_ATTACKS_TO_DO)
	__log_ent("Attacks to do", _attacks_to_do)
	# looks weird, but first attack already set to play in choose_initial_substate
	_attacks_to_do -= 1


func on_exit_state():
	_attacks_to_do = 0


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	if _attacks_to_do >= 0 and current_substate.time_remaining() < 0.15:
		var _attack_number = attack_to_number[current_substate.state_name]
		_next_state = _get_i_attack(_attack_number + 1)
		_attacks_to_do -= 1
		_reason = pp.s("picked next attack with number ", _attack_number + 1, "attacks remained", _attacks_to_do)

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = _get_i_attack(0)
	_reason = "picked first from attacks"
	return VerdictPH.new(_next_state, _reason)


func _get_i_attack(attack_number: int) -> String:
	var _safe_attack_number = int(fmod(attack_number, len(attack_to_number)))
	for attack_name in attack_to_number:
		var _number: int = attack_to_number[attack_name]
		if _number == _safe_attack_number:
			return attack_name
	return ""
