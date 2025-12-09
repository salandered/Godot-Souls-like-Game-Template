extends BaseSFXSystem
class_name BaseWeaponSFXSystem


@onready var whoosh_weapon_player_3d: AudioStreamPlayer3D = %WhooshWeaponPlayer3D
@onready var hit_weapon_player_3d: AudioStreamPlayer3D = %HitWeaponPlayer3D


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	pass


func _get_on_signal_asps(sig_container: BaseSignalContainer) -> Array[OnSFXSigASP]:
	# assert(whoosh_weapon_player_3d)
	# assert(hit_weapon_player_3d)
	var _list: Array[OnSFXSigASP] = [
		OnWeaponSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_whoosh_weapon),
			whoosh_weapon_player_3d,
			SFXConstants.Type_.whoosh_weapon,
		),
		OnWeaponSFXSigASP.new(
			self,
			sig_container.get_by_sig_id(SignalName.sfx_hit_weapon),
			hit_weapon_player_3d,
			SFXConstants.Type_.hit_weapon,
		),
	]
	return _list


func set_whoosh_weapon_stream(stream: AudioStream):
	whoosh_weapon_player_3d.stream = stream

func set_hit_weapon_stream(stream: AudioStream):
	hit_weapon_player_3d.stream = stream

## __LOG


func pp_name() -> String:
	return "BaseWeaponSFXSystem"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
