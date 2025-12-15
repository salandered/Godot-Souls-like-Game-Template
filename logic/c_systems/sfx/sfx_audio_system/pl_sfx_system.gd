extends CharacterSFXSystem
class_name PlayerSFXSystem


## fs
@onready var fs_player_3d: AudioStreamPlayer3D = %FSASP3D
@onready var fs_scrape_player_3d: AudioStreamPlayer3D = %FSScrapeASP3D

##
@onready var launch_player_3d: AudioStreamPlayer3D = %LaunchASP3D
@onready var land_player_3d: AudioStreamPlayer3D = %LandASP3D
@onready var whoosh_player_3d: AudioStreamPlayer3D = %WhooshASP3D
@onready var react_on_hit_asp_3d: AudioStreamPlayer3D = %ReactOnHitASP3D
@onready var unique_asp_3d: AudioStreamPlayer3D = %UniqueASP3D


func _get_on_signal_asps(sig_container: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep),
			fs_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep)
		),
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_light),
			fs_player_3d, ## same asp as fs
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_light)
		),
		OnPlScrapeSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_scrape),
			fs_scrape_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_scrape)
		),
		##
		OnPlayerSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_launch),
			launch_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.launch)
		),
		OnCharSigLandASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_land),
			land_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.land)
		),
		OnPlayerSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_whoosh),
			whoosh_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh_char),
		),
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_react_on_hit),
			react_on_hit_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.react_on_hit)
		),
		OnCharacterSigASPUnique.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_unique),
			unique_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.unique)
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
