extends BasePlayerState


func _ready() -> void:
	stamina_drain = 6.0


func check_transition(input_: InputPackage) -> PLVerdict:
	var _verdict = best_next_state_from_input(input_)
	if _verdict.next_state == PS.jump_sprint and get_actual_time_spent() < 0.2:
		return PLVerdict.new("")
	## reads as: we want to stop sprinting, but we sprint a little time right after the landing. 
	## then lets sprint a bit more
	if _verdict.next_state in [PS.run, PS.idle] \
			and prev_global_action().action_name == PS.Act.landing_sprint \
			and get_actual_time_spent() < 0.3:
		return PLVerdict.new("")
	return _verdict