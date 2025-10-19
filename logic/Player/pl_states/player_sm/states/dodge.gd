extends PlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	
	if curr_state_action.passed_marker(Marker.Name.TO_RUN):
		print_.psm_check_trans(state_name, pp.s("passed_marker TO_RUN => choosing best input"))
		var verdict = best_next_state_from_input(input_)
		return verdict

	return PLVerdict.new("")


func on_enter_state(input_: InputPackage) -> void:
	pass


func update(input_: InputPackage, delta: float) -> void:
	# look_at_target(delta)
	pm().move_with_root(delta)
