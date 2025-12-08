extends BaseAudioSystem
class_name BaseWeaponAudioSystem


@onready var whoosh_weapon_player_3d: AudioStreamPlayer3D = %WhooshWeaponPlayer3D
@onready var hit_weapon_player_3d: AudioStreamPlayer3D = %HitWeaponPlayer3D


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	pass


func create_on_signal_players(signals: BaseSignals) -> Array[OnSFXSignalPlayer]:
	return [
		get_whoosh_on_signal_player(signals),
		get_hit_on_signal_player(signals)
	]


func get_whoosh_on_signal_player(signals: BaseWeaponSignals) -> OnWeaponSFXSignalPlayer:
	return OnWeaponSFXSignalPlayer.new(
			self,
			signals.get_SFX_whoosh_weapon(),
			whoosh_weapon_player_3d,
			SfxType.whoosh_weapon.type_name,
		)

func get_hit_on_signal_player(signals: BaseWeaponSignals) -> OnWeaponSFXSignalPlayer:
	return OnWeaponSFXSignalPlayer.new(
			self,
			signals.get_SFX_hit_weapon(),
			hit_weapon_player_3d,
			SfxType.hit_weapon.type_name,
		)

func set_whoosh_weapon_stream(stream: AudioStream):
	whoosh_weapon_player_3d.stream = stream

func set_hit_weapon_stream(stream: AudioStream):
	hit_weapon_player_3d.stream = stream

## __LOG


func pp_name() -> String:
	return "BaseWeaponAudioSystem"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
