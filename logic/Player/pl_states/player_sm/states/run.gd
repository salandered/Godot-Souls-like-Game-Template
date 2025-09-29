extends PlayerState


func check_transition(input: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	return best_input_that_can_be_paid(input)


# region: test usage
# func choose_default_action() -> String:
# 	if not legs_sm.current_action:
# 		push_error("something wrong")
# 	var name_ = legs_sm.current_action.action_name
# 	if not name_:
# 		push_error("something wrong")
# 	return name_
# endregion