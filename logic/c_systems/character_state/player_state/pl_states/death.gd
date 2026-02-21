extends BasePlayerState


func check_transition(input_: InputPackage) -> PLVerdict:
	if get_actual_time_spent() > 3:
		feelings.add_health(feelings.get_max_health())
		return best_next_state_from_input(input_)
	return PLVerdict.new()


func on_enter_state(input) -> void:
	SigUtils.safe_emit_sig_data(
		get_player().get_sig_container().get_by_sig_id(SignalID.sfx_unique),
		{SFXConstants.unique_key: SFXConstants.Unique.player_dead},
		false
	)
	# prints("DEAD START")


func on_exit_state() -> void:
	pass
	# prints("dead END")
