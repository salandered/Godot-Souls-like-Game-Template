extends BasePHState


var is_awaken: bool = false

var _to_awake: bool = true


func check_transition(_delta) -> VerdictPH:
	match current_lower_state.state_name:
		PHEState.sleep:
			if _to_awake:
				return VerdictPH.new(PHEState.awaken)
		PHEState.awaken:
			if current_lower_state.works_longer_than(get_animation_length()):
				is_awaken = true
				# return VerdictPH.new("life")

	return VerdictPH.new()


func choose_internal_state() -> VerdictPH:
	return VerdictPH.new(PHEState.sleep)


func _unhandled_input(event):
	if event.is_action_pressed("awake Gundyr"):
		_to_awake = true
