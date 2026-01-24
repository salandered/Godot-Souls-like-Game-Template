class_name OnPlayerSigASPSwitchWeapon
extends OnPlayerSigASP


const SWITCH_SMITH_SWORD = preload("uid://c4hbub3v7if2p")
const SWITCH_SMALL_PINGA = preload("uid://dgcim7fnpxwu8")


var weapon_id_to_asp_config: Dictionary[String, ASP3DConfig] = {
	WeaponID.smith_sword: ASP3DConfig.new(0.0, -0.0, 5.0, 15.0, 2, 1.0, BusID.GAME_SFX, SWITCH_SMITH_SWORD, 0.12),
	WeaponID.small_pinga_blade: ASP3DConfig.new(0.0, -0.3, 5.0, 15.0, 2, 1.0, BusID.GAME_SFX, SWITCH_SMALL_PINGA, 0.15),
}


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	var mute: bool = false
	var weapon_id := get_weapon_id_from_payload(payload)

	var _asp_config: ASP3DConfig = DictUtils.safe_get_dict_key(weapon_id_to_asp_config, weapon_id, null, WL.WARN)
	if not _asp_config:
		mute = true
	else:
		_asp_config.set_up_asp(self.asp)
		base_vol_db += _asp_config.vol_db_change
		base_pitch += _asp_config.pitch_change

	return VolPitch.new(base_vol_db, base_pitch, mute, _asp_config.from_position)
