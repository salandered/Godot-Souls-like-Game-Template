class_name BaseWeaponSFXSystem
extends BaseSFXSystem


const weapon_additional_data_key := "weapon"

@onready var whoosh_weapon_player_3d: AudioStreamPlayer3D = %WhooshWeaponPlayer3D
@onready var hit_weapon_player_3d: AudioStreamPlayer3D = %HitWeaponPlayer3D


var _weapon: BaseWeapon


func get_hard_dependencies() -> Array[Object]:
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
		OnWeaponSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_whoosh_weapon),
			whoosh_weapon_player_3d,
			SFXConstants.ID_.whoosh_weapon,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.whoosh_weapon)
		),
		OnWeaponSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_hit_weapon),
			hit_weapon_player_3d,
			SFXConstants.ID_.hit_weapon,
			asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.hit_weapon)
		),
	]
	return _list


func set_whoosh_weapon_stream(stream: AudioStream):
	whoosh_weapon_player_3d.stream = stream

func set_hit_weapon_stream(stream: AudioStream):
	hit_weapon_player_3d.stream = stream

## __LOG



func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
