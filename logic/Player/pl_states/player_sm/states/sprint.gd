extends PlayerState


func _ready() -> void:
	stamina_drain = 6.0


func check_transition(input_: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	var _verdict = best_next_state_from_input(input_)
	if _verdict.next_state == PS.jump_sprint and time_spent() < 0.3:
		return PLVerdict.new("") # or second  best state?
	return _verdict