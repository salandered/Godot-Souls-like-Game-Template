@abstract
extends BasePHEComposite
class_name BasePHEAttackSeries


var PL_DIST_TO_END := 8

var _chosen_attack_series: Array[String] = []

## starts with 0
var current_attack_number: int = -1
## starts with 0
var curr_series_number: int = -1

## DOC: 
## 	  - WARNING: Only Leaf states are supported as attacks. 
##			     In other words, BasePHEAttackSeries can not have BasePHEComposite as a substate.
##	  - Implement get_attack_series_list() which returns non empty series
##	  - Implement pick_series_idx. Simplest: call default_pick_series_idx()
##    - Recommended: set config values in initialise()
##	  - NOTE: i decided to do @abstract methods and default implementation as an alternative to 
##            do just method and overrding it in heirs See how it goes. 
##            Idea is that u think of logic when creating new series, and u cant make a mistake in function name while overriding

## returns Array[Array[String]]. 
## E.g  [ ["attack_a"], ["attack_a", "attack_b"] ]
@abstract func get_attack_series_list() -> Array


@abstract func pick_series_idx() -> int

## current_substate is guaranteed to be not null
@abstract func condition_to_next_switch(current_substate: BasePHELeaf) -> bool

## usually it the same as condition_to_next_switch
## current_substate is guaranteed to be not null
@abstract func condition_to_end(current_substate: BasePHELeaf) -> bool


## Most basic implementations for abstract methold (not dead code, used in simple serieses or as a fallback)
# region
func default_pick_series_idx() -> int:
	var random_index := randi_range(0, get_attack_series_list().size() - 1)
	return random_index

## To tweak if using default conditions
var SWITCH_ANIM_BEFORE := 0.2

func default_condition_to_next_switch(current_substate: BasePHELeaf) -> bool:
	return current_substate.time_remaining() < SWITCH_ANIM_BEFORE

func default_condition_to_end(current_substate: BasePHELeaf) -> bool:
	return current_substate.time_remaining() < SWITCH_ANIM_BEFORE
# endregion


# helpers

## returns false on any problem occurred (and of not marker passed lol)
func attack_in_series_passed_marker(curr_series_number_: int, curr_sbs: BasePHELeaf, target_sbs_name_: String, marker_name: String) -> bool:
	if curr_series_number != curr_series_number_:
		return false
	
	if curr_sbs.state_name != target_sbs_name_:
		return false

	if not curr_sbs.anim.does_marker_exist(marker_name):
		return false

	if curr_sbs.passed_marker(marker_name):
		__log_upd("captured attack_in_series_passed_marker", curr_series_number_, curr_sbs.state_name, target_sbs_name_, marker_name)
		return true

	return false

func _flatten_attack_series_list() -> Array[String]:
	var unique_dict := {}
	for series in get_attack_series_list():
		for attack in series:
			unique_dict[attack] = true
	return u.safe_cast_array_of_strings(unique_dict.keys())


func get_supported_substates() -> Array[String]:
	var state_list := _flatten_attack_series_list()
	for state_name_ in state_list:
		var state := container.get_state_by_name(state_name_)
		# '\' helps against formatter
		assert(state is \
			BasePHELeaf)
	return state_list


func is_ended() -> bool:
	return _is_ended()


func _is_ended() -> bool:
	var _r: bool = true # safer to assume its true by default
	var _reason: String = ""
	var _current_substate := get_current_substate()
	
	if _current_substate == null:
		__log_upd('_is_ended', "_current_substate is null", 'curr attack idx', current_attack_number, _chosen_attack_series)
		return true

	if dist_to_player_greater(PL_DIST_TO_END) and condition_to_end(_current_substate):
		_reason += "dist > PL_DIST_TO_END and condition_to_end (hard stop if player is far way and we ended current attack) "
		_r = true
	elif not condition_to_end(_current_substate):
		_reason += "not condition_to_end (in the middle of curr attack)"
		_r = false
	elif current_attack_number + 1 < _chosen_attack_series.size():
		_reason += "have more attacks to do in the combo"
		_r = false
	else:
		_reason += "empty else caught, by defailt we end"
	
	if _r == true:
		__log_upd('_is_ended', 'curr attack idx/idx+1/size %d %d %d' % [current_attack_number, current_attack_number + 1, _chosen_attack_series.size()],
			 _current_substate.time_remaining(), _chosen_attack_series, "cond_to_end", condition_to_end(_current_substate), "Reason:", _reason)
	
	return _r

func on_enter_state() -> void:
	_series_forgotten.turn_off()
	

func on_exit_state() -> void:
	_chosen_attack_series = []
	current_attack_number = -1
	curr_series_number = -1

var _series_forgotten := DelayTimer.new()

func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var current_substate_casted: BasePHELeaf = current_substate # safe, see get_supported_substates
	
	var _switch_on_same := false
	var _override_commit := false
	
	if condition_to_next_switch(current_substate_casted):
		var _next_index := current_attack_number + 1
		__log_upd("attack index + 1. curr/next", current_attack_number, _next_index)
		if _next_index < _chosen_attack_series.size(): # next attack exists
			# __log_upd("gonna switch to next attack curr/next", current_attack_number, _next_index)
			current_attack_number = _next_index
			_next_state = _chosen_attack_series[current_attack_number]
			var _remaining := _chosen_attack_series.size() - (current_attack_number + 1)
			_reason += pp.s("advancing attack series", "attacks remaining", _remaining)
			_switch_on_same = true
			_override_commit = true
		else:
			# NOTE: we don't change current_attack_number here. is_ended should be true
			if not _series_forgotten.is_initialised():
				# __log_warn(false, "_series_forgotten init!")
				_series_forgotten.initialise(0.1)
				_reason += pp.s(em.warn, "series ended! parent not switches us! wait 0.1 sec and return one more move with idx 0")
				return VerdictPH.new(_next_state, _reason)
			elif _series_forgotten.update(delta):
				__log_warn(false, "_series_forgotten update!")
				_reason += pp.s("0.1 passed, one more move")
				_series_forgotten.turn_off()
				_next_state = _chosen_attack_series[0]
				_switch_on_same = true
				_override_commit = true
				
	return VerdictPH.new(_next_state, _reason, _switch_on_same, _override_commit)


func pick_attack_series() -> Array[String]:
	if get_attack_series_list().is_empty():
		__log_warn(true, "pick_attack_series: 'attack_series_list' list is empty!", "Fallback: return []")
		return []
	var picked_idx := pick_series_idx()
	
	if picked_idx < 0 or picked_idx >= get_attack_series_list().size():
		__log_warn(false, "picked_idx", picked_idx, "is outside the", get_attack_series_list(), "Fallback: will pick 0 index")
		picked_idx = 0
		
	var picked_series: Array = get_attack_series_list()[picked_idx]
	curr_series_number = picked_idx
	return u.safe_cast_array_of_strings(picked_series)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_chosen_attack_series = pick_attack_series()
	
	if _chosen_attack_series.is_empty():
		_reason = "No valid combo found"
	else:
		current_attack_number = 0
		_next_state = _chosen_attack_series[current_attack_number]
		_reason = "picked combo, starting with first attack"
	
	__log_ent("Chosen combo:", _chosen_attack_series, "| Total attacks:", _chosen_attack_series.size())
	return VerdictPH.new(_next_state, _reason)
