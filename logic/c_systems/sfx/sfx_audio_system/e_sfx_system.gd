extends CharacterSFXSystem
class_name EnemySFXSystem


## fs like
@onready var fs_player_3d: AudioStreamPlayer3D = %FSASP3D
@onready var fs_bass_player_3d: AudioStreamPlayer3D = %FSASPBass
@onready var fs_scrape_player_3d: AudioStreamPlayer3D = %FSScrapeASP3D
@onready var move_noise_asp_3d: AudioStreamPlayer3D = %MoveNoiseASP3D
@onready var jingles_asp_3d: AudioStreamPlayer3D = %JinglesASP3D
##
@onready var launch_player_3d: AudioStreamPlayer3D = %LaunchASP3D
@onready var land_player_3d: AudioStreamPlayer3D = %LandASP3D
@onready var whoosh_asp_3d: AudioStreamPlayer3D = %WhooshASP3D
@onready var react_on_hit_asp_3d: AudioStreamPlayer3D = %ReactOnHitASP3D
@onready var unique_asp_3d: AudioStreamPlayer3D = %UniqueASP3D


func _get_on_signal_asps(sig_container: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs like
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep),
			fs_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep)
		),
		# BASS
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep),
			fs_bass_player_3d,
			ASPConfig.new(2.0, -0.2, 4.0, 60.0, 3, 0.1)
		),
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_light),
			fs_player_3d, ## same asp as fs
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_light)
		),
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_scrape),
			fs_scrape_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_scrape)
		),
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_move_noise),
			move_noise_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.move_noise)
		),
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_move_noise),
			jingles_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.jingles)
		),
		##
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_launch),
			launch_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.launch)
		),
		OnCharSigLandASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_land),
			land_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.land)
		),
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_whoosh),
			whoosh_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh_char)
		),
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_react_on_hit),
			react_on_hit_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.react_on_hit)
		),
		OnCharacterSigASPUnique.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_unique),
			unique_asp_3d,
			null
		),
	]
	for item: OnSFXSigASP in _list:
		item._log_tag = get_character().pp_name()
	return _list

## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
