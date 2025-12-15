@abstract
class_name BaseCharacterSignalContainer
extends BaseSignalContainer


## DANGER: private, use BaseSignalContainer api
## fs like
signal SFX_footstep(payload: Dictionary[String, Variant])
signal SFX_footstep_light(payload: Dictionary[String, Variant])
signal SFX_footstep_scrape(payload: Dictionary[String, Variant])
signal SFX_move_noise(payload: Dictionary[String, Variant])
##
signal SFX_launch(payload: Dictionary[String, Variant])
signal SFX_land(payload: Dictionary[String, Variant])
signal SFX_whoosh(payload: Dictionary[String, Variant])
signal SFX_react_on_hit(payload: Dictionary[String, Variant])
##
signal SFX_unique(payload: Dictionary[String, Variant])


func _get_signal_data_list() -> Array[SignalData]:
	var signal_data_list: Array[SignalData] = [
		## fs
		SignalData.new(SignalID.sfx_footstep, SFX_footstep),
		SignalData.new(SignalID.sfx_footstep_light, SFX_footstep_light),
		SignalData.new(SignalID.sfx_footstep_scrape, SFX_footstep_scrape),
		SignalData.new(SignalID.sfx_move_noise, SFX_move_noise),
		##
		SignalData.new(SignalID.sfx_launch, SFX_launch),
		SignalData.new(SignalID.sfx_land, SFX_land),
		SignalData.new(SignalID.sfx_whoosh, SFX_whoosh),
		SignalData.new(SignalID.sfx_react_on_hit, SFX_react_on_hit),
		##
		SignalData.new(SignalID.sfx_unique, SFX_unique),
	]
	
	signal_data_list.append_array(_get_character_specific_signal_data_list())
	
	return signal_data_list


## called on init only
@abstract func _get_character_specific_signal_data_list() -> Array[SignalData]
