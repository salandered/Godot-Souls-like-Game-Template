@abstract
class_name BaseCharacterSADContainer
extends BaseSADContainer


func _get_sad_list() -> Array[SFXAnimData]:
	## fs
	var _list: Array[SFXAnimData] = [
		## fs
		SFXAnimData.new(
			SFXConstants.Type_.footstep,
			"FS",
			SignalName.sfx_footstep
			),
		SFXAnimData.new(
			SFXConstants.Type_.footstep_light,
			"FSLight",
			SignalName.sfx_footstep_light
			),
		SFXAnimData.new(
			SFXConstants.Type_.footstep_scrape,
			"FSScrape",
			SignalName.sfx_footstep_scrape
			),
		## 
		SFXAnimData.new(
			SFXConstants.Type_.launch,
			"Launch",
			SignalName.sfx_launch
			),
		SFXAnimData.new(
			SFXConstants.Type_.land,
			"Land",
			SignalName.sfx_land
			),
		SFXAnimData.new(
			SFXConstants.Type_.whoosh,
			"WH",
			SignalName.sfx_whoosh
			),
		## weapon
		
	]

	_list.append_array(_get_character_specific_sad_list())

	return _list


@abstract func _get_character_specific_sad_list() -> Array[SFXAnimData]
