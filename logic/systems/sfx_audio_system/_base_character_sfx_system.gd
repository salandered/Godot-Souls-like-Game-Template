@abstract
class_name CharacterSFXSystem
extends BaseSFXSystem


const character_additional_data_key := "character"


@abstract func get_fs_player_3d() -> AudioStreamPlayer3D

@abstract func get_fs_scrape_player_3d() -> AudioStreamPlayer3D

@abstract func get_launch_player_3d() -> AudioStreamPlayer3D

@abstract func get_land_player_3d() -> AudioStreamPlayer3D

@abstract func get_whoosh_player_3d() -> AudioStreamPlayer3D

# @abstract func get_react_on_hit_player_3d() -> AudioStreamPlayer3D


var _character: BaseCharacter


func get_character() -> BaseCharacter:
	if not _character:
		__log_error("_character is null", "CharacterSFXSystem", "", "this should not happen")
	return _character


func _get_on_signal_asps(sig_container: BaseSignalContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs
		OnCharacterSFXFSUsualSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep),
			get_fs_player_3d(),
			SFXConstants.Type_.footstep,
		),
		OnCharacterSFXFSLightSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_light),
			get_fs_player_3d(),
			SFXConstants.Type_.footstep_light,
		),
		OnCharacterSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_scrape),
			get_fs_scrape_player_3d(),
			SFXConstants.Type_.footstep_scrape,
		),
		##
		OnCharacterSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_launch),
			get_launch_player_3d(),
			SFXConstants.Type_.launch,
		),
		OnCharacterSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_land),
			get_land_player_3d(),
			SFXConstants.Type_.land,
		),
		OnCharacterSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_whoosh),
			get_whoosh_player_3d(),
			SFXConstants.Type_.whoosh,
		),
	]
	return _list


# endregion


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	_character = u.safe_get_dict_key(additional_data, character_additional_data_key, null)


## Character states

@abstract func get_character_run_state_name() -> String

@abstract func get_character_sprint_state_name() -> String


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
