@abstract
class_name BaseCharacterSADContainer
extends BaseSADContainer


func _get_sad_list() -> Array[SFXAnimData]:
	## fs
	var _list: Array[SFXAnimData] = [
		## fs
		SFXAnimData.new(
			SFXConstants.ID_.footstep,
			"FS",
			SignalID.sfx_footstep
			),
		SFXAnimData.new(
			SFXConstants.ID_.footstep_light,
			"FSLight",
			SignalID.sfx_footstep_light
			),
		SFXAnimData.new(
			SFXConstants.ID_.footstep_scrape,
			"FSScrape",
			SignalID.sfx_footstep_scrape
			),
		SFXAnimData.new(
			SFXConstants.ID_.move_noise,
			"Move",
			SignalID.sfx_move_noise
			),
		## 
		SFXAnimData.new(
			SFXConstants.ID_.launch,
			"Launch",
			SignalID.sfx_launch
			),
		SFXAnimData.new(
			SFXConstants.ID_.land,
			"Land",
			SignalID.sfx_land
			),
		SFXAnimData.new(
			SFXConstants.ID_.whoosh_char,
			"WH",
			SignalID.sfx_whoosh
			),
		## weapon
		
	]

	_list.append_array(_get_character_specific_sad_list())

	return _list


@abstract func _get_character_specific_sad_list() -> Array[SFXAnimData]
