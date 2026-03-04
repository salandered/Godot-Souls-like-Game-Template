class_name BaseWeaponSignalContainer
extends BaseSignalContainer


## NOTE: treated as not an abstract class for simplicity 
## consider it weapons will need many specific signals


## DANGER: private, use BaseSignalContainer api
signal SFX_whoosh_weapon(payload: Dictionary[StringName, Variant])
signal SFX_hit_weapon(payload: Dictionary[StringName, Variant])
signal SFX_hit_target(payload: Dictionary[StringName, Variant])


func _get_signal_data_list() -> Array[SignalData]:
	var signal_data_list: Array[SignalData] = [
		## fs
		SignalData.new(SignalID.sfx_whoosh_weapon, SFX_whoosh_weapon),
		SignalData.new(SignalID.sfx_hit_weapon, SFX_hit_weapon),
		SignalData.new(SignalID.sfx_hit_target, SFX_hit_target),
	]
	
	signal_data_list.append_array(_get_all_weapon_specific_signals())
	
	return signal_data_list


func _get_all_weapon_specific_signals() -> Array[SignalData]:
	return []


func __LOG_INDENT() -> int:
	return 0
