class_name OnCharacterSigASPUnique
extends OnCharacterSigASP

const PICKING_9 = preload("uid://cntg7xya48dal")
const ACCOMPLISH = preload("uid://b51cbgqh3orc7")


var unique_asp_configs: Dictionary[String, ASP3DConfig] = {
	SFXConstants.Unique.phase_switch: ASP3DConfig.new(1.0, -0.3, 5.0, 50.0, 4, 0.5, BusID.GAME_SFX, PICKING_9),
	SFXConstants.Unique.accomplish: ASP3DConfig.new(1.0, -0.3, 3.0, 20.0, 4, 0.2, BusID.GAME_SFX, ACCOMPLISH),
	SFXConstants.Unique.player_dead: ASP3DConfig.new(2.0, -0.2, 2.0, 20.0, 4, 0.9, BusID.GAME_SFX, PICKING_9)
}


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	var mute: bool = false
	var unique_value := get_unique_from_payload(payload)

	var _asp_config: ASP3DConfig = u.safe_get_dict_key(unique_asp_configs, unique_value, null, WL.SILENT)
	if not _asp_config:
		mute = true
	else:
		if unique_value == "player_dead":
			__log_("play dead! play")
		_asp_config.set_up_asp(self.asp)
		base_vol_db += _asp_config.vol_db_change
		base_pitch += _asp_config.pitch_change
	return VolPitch.new(base_vol_db, base_pitch, mute)


## __LOGS
# region


func __LOG_B() -> bool:
	return true


# endregion
