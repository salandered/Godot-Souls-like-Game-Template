class_name BaseWeaponSFXSystem
extends BaseSFXSystem


const weapon_additional_data_key := "weapon"

@onready var whoosh_weapon_player_3d: AudioStreamPlayer3D = %WhooshWeaponPlayer3D
@onready var hit_weapon_player_3d: AudioStreamPlayer3D = %HitWeaponPlayer3D
@onready var hit_target_weapon_player_3d: AudioStreamPlayer3D = %HitTargetWeaponPlayer3D


var _weapon: BaseWeapon


func __hard_dependencies() -> Array[Object]:
	return [
		whoosh_weapon_player_3d,
		hit_weapon_player_3d,
		_weapon
	]


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	_weapon = u.safe_get_dict_key(additional_data, weapon_additional_data_key, null)


## non nullable
func get_weapon() -> BaseWeapon:
	return _weapon


func _get_on_signal_asps(sig_container: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]:
	var _list: Array[OnSFXSigASP] = [
		OnWeaponSFXSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_whoosh_weapon),
			whoosh_weapon_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh_weapon),
		),
		OnWeaponSFXSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_hit_weapon),
			hit_weapon_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.hit_weapon),
		),
		OnWeaponSFXSigASP.new(self,
			sig_container.get_by_sig_id(SignalID.sfx_hit_target),
			hit_target_weapon_player_3d,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.hit_target),
		),
	]

	for item: OnSFXSigASP in _list:
		item._log_tag = get_weapon().get_weapon_id()
	return _list


## __LOG


func pp_name() -> String:
	var prefix = get_weapon().get_weapon_id() if get_weapon() else ""
	return pp.s(prefix, u.construct_obj_pp_name(self))
