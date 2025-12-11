class_name WeaponSADContainer
extends BaseSADContainer


func _get_sad_list() -> Array[SFXAnimData]:
	var _list: Array[SFXAnimData] = [
		SFXAnimData.new(
			SFXConstants.ID_.whoosh_weapon,
			"WHWeapon",
			SignalName.sfx_whoosh_weapon
			),
	]

	_list.append_array(_get_weapon_specific_sad_list())

	return _list


## reminder that this could be done similar to character sad container.
func _get_weapon_specific_sad_list() -> Array[SFXAnimData]:
	return []
