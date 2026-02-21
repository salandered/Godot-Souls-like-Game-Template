class_name OnPlScrapeSigASP
extends OnPlayerSigASP


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[StringName, Variant]) -> VolPitch:
	match get_curr_action_name():
		Leg.Act.turn_180:
			base_vol_db -= 4.0
		Leg.Act.idle_to_sprint:
			base_vol_db -= 4.0
	return VolPitch.new(base_vol_db, base_pitch)
