class_name AuraWeaponSADContainer
extends WeaponSADContainer


func _get_sad_list() -> Array[SFXAnimData]:
	var _list: Array[SFXAnimData] = [
		SFXAnimData.new(
		SFXConstants.ID_.whoosh_weapon,
		"WHAuraWp",
		SignalID.sfx_whoosh_weapon
		),
	]


	return _list
