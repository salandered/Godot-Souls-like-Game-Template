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


func _get_on_signal_asps(sig_container: BaseSignalContainer, sfx_configs: Dictionary[String, SFXStreamConfig]) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs
		OnCharSigFSUsualASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep),
			get_fs_asp_3d(),
			SFXConstants.Type_.footstep,
			sfx_configs.get(SFXConstants.Type_.footstep)
		),
		OnCharSigFSLightASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_light),
			get_fs_asp_3d(), ## same asp as fs
			SFXConstants.Type_.footstep_light,
			sfx_configs.get(SFXConstants.Type_.footstep_light)
		),
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_footstep_scrape),
			get_fs_scrape_asp_3d(),
			SFXConstants.Type_.footstep_scrape,
			sfx_configs.get(SFXConstants.Type_.footstep_scrape)
		),
		##
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_launch),
			get_launch_asp_3d(),
			SFXConstants.Type_.launch,
			sfx_configs.get(SFXConstants.Type_.launch)
		),
		OnCharSigLandASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_land),
			get_land_asp_3d(),
			SFXConstants.Type_.land,
			sfx_configs.get(SFXConstants.Type_.land)
		),
		OnCharacterSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_whoosh),
			get_whoosh_asp_3d(),
			SFXConstants.Type_.whoosh,
			sfx_configs.get(SFXConstants.Type_.whoosh)
		),
	]
	return _list


# endregion


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
