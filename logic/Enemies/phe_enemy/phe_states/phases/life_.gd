extends BasePHState


var phase_switch_hp_treshold := 0.5 # % of maximum
var pursuit_radius: float = 8
var max_chill_time: float = 25
var min_chill_time: float = 15
var will_pursue_for: float = 15


func check_transition(_delta) -> VerdictPH:
	var _next_state := "" # is valid value if no switch occurs
	var _reason := ""
	if phe_feelings.health < 1:
		_reason = "health < 1"
		_next_state = PHEState.death

	match current_lower_state.state_name:
		PHEState.still_life_phase:
			if current_lower_state.is_awaken:
				_reason = "is_awaken"
				_next_state = PHEState.pursuing_phase
		PHEState.pursuing_phase:
			# will_pursue_for = randf_range(min_chill_time, max_chill_time)
			will_pursue_for = 999999
			if current_lower_state.works_longer_than(will_pursue_for): # or distance_to_player() < pursuit_radius():
				_reason = "works_longer_than will_pursue_for"
				_next_state = PHEState.combat_phase

	# later
	# 	if phe_feelings.health < phe_feelings.max_health * phase_switch_hp_treshold:
	# 		return VerdictPH.new(PHEState.combat_phase_angry)
	# (Add logic for Combat_1 -> Chill_1 here when ready)
	# if current_state.state_name == "combat_1" and ... :
	# 	return VerdictPH.new("chill_1")
	var _verdict = VerdictPH.new(_next_state)
	return VerdictPH.new()


func choose_internal_state() -> VerdictPH:
	return VerdictPH.new(PHEState.still_life_phase)
