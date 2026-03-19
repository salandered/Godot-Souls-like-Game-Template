extends CharacterSFXSystem
class_name ESitSKSFXSystem


## fs like
@onready var fs_player_3d: AudioStreamPlayer3D = %FSASP3D
@onready var move_noise_asp_3d: AudioStreamPlayer3D = %MoveNoiseASP3D
##
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
		OnCharFSSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_footstep_light),
			fs_player_3d, ## same asp as fs
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep_light)
		),
	
		OnCharacterSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_move_noise),
			move_noise_asp_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.move_noise)
		),
	
		##
	
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
