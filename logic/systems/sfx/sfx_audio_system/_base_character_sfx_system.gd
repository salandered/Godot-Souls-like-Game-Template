@abstract
class_name CharacterSFXSystem
extends BaseSFXSystem


const character_additional_data_key := "character"


@abstract func get_fs_asp_3d() -> AudioStreamPlayer3D

@abstract func get_fs_scrape_asp_3d() -> AudioStreamPlayer3D

@abstract func get_launch_asp_3d() -> AudioStreamPlayer3D

@abstract func get_land_asp_3d() -> AudioStreamPlayer3D

@abstract func get_whoosh_asp_3d() -> AudioStreamPlayer3D

# @abstract func get_react_on_hit_asp_3d() -> AudioStreamPlayer3D


var _character: BaseCharacter


func get_hard_dependencies() -> Array[Object]:
	return [
		get_fs_asp_3d(),
		get_fs_scrape_asp_3d(),
		get_launch_asp_3d(),
		get_land_asp_3d(),
		get_whoosh_asp_3d(),
		_character
	]


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	_character = u.safe_get_dict_key(additional_data, character_additional_data_key, null)


## non nullable
func get_character() -> BaseCharacter:
	return _character


func _get_on_signal_asps(sig_container: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs
		OnCharFSSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep),
			get_fs_asp_3d(),
			SFXConstants.ID_.footstep,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep)
		),
		OnCharFSSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_light),
			get_fs_asp_3d(), ## same asp as fs
			SFXConstants.ID_.footstep_light,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_light)
		),
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_scrape),
			get_fs_scrape_asp_3d(),
			SFXConstants.ID_.footstep_scrape,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_scrape)
		),
		##
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_launch),
			get_launch_asp_3d(),
			SFXConstants.ID_.launch,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.launch)
		),
		OnCharSigLandASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_land),
			get_land_asp_3d(),
			SFXConstants.ID_.land,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.land)
		),
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_whoosh),
			get_whoosh_asp_3d(),
			SFXConstants.ID_.whoosh,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh)
		),
	]
	return _list


# endregion


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
