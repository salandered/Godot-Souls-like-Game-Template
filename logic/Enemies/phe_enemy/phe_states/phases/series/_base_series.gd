@abstract
extends BasePHEComposite
class_name BasePHEAttackSeries

## To tweak in implementation
var SWITCH_ANIM_BEFORE = 0.2
var PL_DIST_TO_END = 8


var _chosen_attack_series: Array[String] = []
var _current_attack_idx: int = -1


## NOTE DOC: 
##	  - Implement get_attack_series_list() which returns non empty series
##	  - Implement pick_series_idx. Simplest: call default_pick_series_idx()
##    - Recommended: set config values in initialise()
##

## Result is like this: [ ["attack_a"], ["attack_a", "attack_b"] ]
@abstract func get_attack_series_list() -> Array

@abstract func pick_series_idx() -> int


## Most basic implementation for pick_series_idx
func default_pick_series_idx() -> int:
	var random_index = randi_range(0, get_attack_series_list().size() - 1)
	return random_index


func _flatten_attack_series_list() -> Array[String]:
	var unique_dict := {}
	for series in get_attack_series_list():
		for attack in series:
			unique_dict[attack] = true
	return u.safe_cast_array_of_strings(unique_dict.keys())


func get_supported_substates() -> Array[String]:
	return _flatten_attack_series_list()


func is_ended() -> bool:
	return _is_ended()


func _is_ended() -> bool:
	var _r: bool = true # safer to assume its true by default
	var _current_substate = get_current_substate()
	
	if _current_substate == null:
		return true

	# hard stop if player is far way and we ended current attack
	if dist_to_player_greater(PL_DIST_TO_END) and _current_substate.time_remaining() < SWITCH_ANIM_BEFORE:
		_r = true
	# in the middle of curr attack
	elif _current_substate.time_remaining() > SWITCH_ANIM_BEFORE:
		_r = false
	# have more attacks to do in the combo
	elif _current_attack_idx + 1 < _chosen_attack_series.size():
		_r = false
	
	if _r == true:
		__log_upd('_is_ended', 'curr attack idx', _current_attack_idx, _current_substate.time_remaining(), _chosen_attack_series)
	
	return _r


func on_exit_state():
	_chosen_attack_series = []
	_current_attack_idx = -1


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	if current_substate.time_remaining() < SWITCH_ANIM_BEFORE:
		var _next_index = _current_attack_idx + 1
		if _next_index < _chosen_attack_series.size(): # next attack exists
			_current_attack_idx = _next_index
			_next_state = _chosen_attack_series[_current_attack_idx]
			var _remaining = _chosen_attack_series.size() - (_current_attack_idx + 1)
			_reason = pp.s("advancing attack series to idx", _current_attack_idx, "attacks remaining", _remaining)

	return VerdictPH.new(_next_state, _reason)


func pick_attack_series() -> Array[String]:
	if get_attack_series_list().is_empty():
		__log_warn(true, "pick_attack_series: 'attack_series_list' list is empty!", "Fallback: return []")
		return []
	var picked_idx = pick_series_idx()
	
	if picked_idx < 0 or picked_idx >= get_attack_series_list().size():
		__log_warn(true, "picked_idx", picked_idx, "is outside the", get_attack_series_list(), "Fallback: will pick 0 index")
		picked_idx = 1
		
	var picked_series = get_attack_series_list()[picked_idx]
	return u.safe_cast_array_of_strings(picked_series)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_chosen_attack_series = pick_attack_series()
	
	if _chosen_attack_series.is_empty():
		_reason = "No valid combo found"
	else:
		_current_attack_idx = 0
		_next_state = _chosen_attack_series[_current_attack_idx]
		_reason = "picked combo, starting with first attack"
	
	__log_ent("Chosen combo:", _chosen_attack_series, "| Total attacks:", _chosen_attack_series.size())
	return VerdictPH.new(_next_state, _reason)
