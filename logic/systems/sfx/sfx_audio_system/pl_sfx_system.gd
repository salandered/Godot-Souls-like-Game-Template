extends CharacterSFXSystem
class_name PlayerSFXSystem


@onready var fs_player_3d: AudioStreamPlayer3D = %FSASP3D
@onready var fs_scrape_player_3d: AudioStreamPlayer3D = %FSScrapeASP3D
@onready var launch_player_3d: AudioStreamPlayer3D = %LaunchASP3D
@onready var land_player_3d: AudioStreamPlayer3D = %LandASP3D
@onready var whoosh_player_3d: AudioStreamPlayer3D = %WhooshASP3D
# @onready var react_on_hit_player_3d: AudioStreamPlayer3D = %ReactOnHitPlayer3D


func get_fs_asp_3d() -> AudioStreamPlayer3D:
	return fs_player_3d

func get_fs_scrape_asp_3d() -> AudioStreamPlayer3D:
	return fs_scrape_player_3d

func get_launch_asp_3d() -> AudioStreamPlayer3D:
	return launch_player_3d

func get_land_asp_3d() -> AudioStreamPlayer3D:
	return land_player_3d

func get_whoosh_asp_3d() -> AudioStreamPlayer3D:
	return whoosh_player_3d

# func get_react_on_hit_asp_3d() -> AudioStreamPlayer3D:
# 	return react_on_hit_player_3d


func _get_on_signal_asps(sig_container: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		## fs
		OnCharFSSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep),
			get_fs_asp_3d(),
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep)
		),
		OnCharFSSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_light),
			get_fs_asp_3d(), ## same asp as fs
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_light)
		),
		OnPlScrapeSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_scrape),
			get_fs_scrape_asp_3d(),
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_scrape)
		),
		##
		OnPlayerSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_launch),
			get_launch_asp_3d(),
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.launch)
		),
		OnCharSigLandASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_land),
			get_land_asp_3d(),
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.land)
		),
		OnPlayerSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalID.sfx_whoosh),
			get_whoosh_asp_3d(),
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh)
		),
	]
	return _list


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
