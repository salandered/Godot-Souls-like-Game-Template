extends BasePHEComposite


func initialise() -> void:
	u.safe_connect(PlayerStats.SIG_dodge_combo_achieved, _on_SIG_dodge_combo_achieved)
	u.safe_connect(PlayerStats.SIG_power_combo_achieved, _on_SIG_power_combo_achieved)
	u.safe_connect(PlayerStats.SIG_plush_launched, _on_SIG_plush_launched)
	u.safe_connect(PlayerStats.SIG_sitting_skeleton_is_not_happy, _on_SIG_sitting_skeleton_is_not_happy)
	u.safe_connect(PlayerStats.SIG_simple_target_super_rotate, _on_SIG_simple_target_super_rotate)


var interrupted_state: String = ""


func _on_SIG_dodge_combo_achieved():
	interrupted_state = SITSKS.Leaf.sit_laugh

func _on_SIG_power_combo_achieved():
	interrupted_state = SITSKS.Leaf.sit_point

func _on_SIG_plush_launched():
	interrupted_state = SITSKS.Leaf.sit_clap

func _on_SIG_sitting_skeleton_is_not_happy():
	interrupted_state = SITSKS.Leaf.sit_intimidate

func _on_SIG_simple_target_super_rotate():
	interrupted_state = SITSKS.Leaf.sit_clap


func get_supported_substates() -> Array[String]:
	return [
		## idle
		SITSKS.Leaf.sit_idle_v1,
		SITSKS.Leaf.sit_idle_v2,
		SITSKS.Leaf.sit_talking,
		SITSKS.Leaf.sit_rubbing,
		SITSKS.Leaf.sit_intimidate,
		## one time
		SITSKS.Leaf.sit_point,
		SITSKS.Leaf.sit_clap,
		SITSKS.Leaf.sit_disbelief,
		SITSKS.Leaf.sit_laugh,
	]


var initial_spick_weighted: Dictionary[String, float] = {
	SITSKS.Leaf.sit_idle_v1: 0.4,
	SITSKS.Leaf.sit_idle_v2: 0.1,
	SITSKS.Leaf.sit_intimidate: 0.2,
	SITSKS.Leaf.sit_talking: 0.2,
}


var basic_spick_weighted: Dictionary[String, float] = {
	## idle
	SITSKS.Leaf.sit_idle_v1: 0.5,
	SITSKS.Leaf.sit_idle_v2: 0.1,
	SITSKS.Leaf.sit_rubbing: 0.3,
	SITSKS.Leaf.sit_talking: 0.3,
	SITSKS.Leaf.sit_intimidate: 0.1,
	## one time
	SITSKS.Leaf.sit_point: 0.1,
	SITSKS.Leaf.sit_disbelief: 0.1,
	SITSKS.Leaf.sit_laugh: 0.1
}

# var not_happy_spick_weighted: Dictionary[String, float] = {
# 	SITSKS.Leaf.sit_intimidate: 0.4,
# }


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	if current_substate.is_ended():
		match current_substate.state_name:
			SITSKS.Leaf.sit_idle_v1, SITSKS.Leaf.sit_idle_v2:
				_next_state = ra.spick_weighted(basic_spick_weighted)
			SITSKS.Leaf.sit_rubbing, SITSKS.Leaf.sit_talking, SITSKS.Leaf.sit_intimidate:
				_next_state = ra.spick_weighted(basic_spick_weighted)
			SITSKS.Leaf.sit_point, SITSKS.Leaf.sit_disbelief, SITSKS.Leaf.sit_laugh:
				_next_state = ra.spick_weighted(basic_spick_weighted)
			_:
				_next_state = ra.spick_weighted(basic_spick_weighted)

	if interrupted_state != "":
		if current_substate.state_name != interrupted_state:
			_next_state = interrupted_state
		interrupted_state = ""


	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = ra.spick_weighted(initial_spick_weighted)
	return VerdictPH.new(SITSKS.Leaf.sit_idle_v1)
