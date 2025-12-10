@abstract
class_name BaseCharacterSignalContainer
extends BaseSignalContainer


## DANGER: private, use BaseSignalContainer api
## fs
signal SFX_footstep(payload: Dictionary[String, Variant])
signal SFX_footstep_light(payload: Dictionary[String, Variant])
signal SFX_footstep_scrape(payload: Dictionary[String, Variant])
##
signal SFX_launch(payload: Dictionary[String, Variant])
signal SFX_land(payload: Dictionary[String, Variant])
signal SFX_whoosh(payload: Dictionary[String, Variant])
# signal SFX_react_on_hit


func _get_signal_data_list() -> Array[SignalData]:
	var signal_data_list: Array[SignalData] = [
		## fs
		SignalData.new(SignalName.sfx_footstep, SFX_footstep),
		SignalData.new(SignalName.sfx_footstep_light, SFX_footstep_light),
		SignalData.new(SignalName.sfx_footstep_scrape, SFX_footstep_scrape),
		##
		SignalData.new(SignalName.sfx_launch, SFX_launch),
		SignalData.new(SignalName.sfx_land, SFX_land),
		SignalData.new(SignalName.sfx_whoosh, SFX_whoosh),
	]
	
	signal_data_list.append_array(_get_character_specific_signal_data_list())
	
	return signal_data_list


## called on init only
@abstract func _get_character_specific_signal_data_list() -> Array[SignalData]
