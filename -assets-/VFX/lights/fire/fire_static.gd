@tool
class_name FireStatic
extends FlickerOmni


@export_group("Sound Settings")
@export var play_sound: bool = true:
	set(value):
		play_sound = value
		if is_node_ready(): _apply_sound_settings()


func _ready_implementation() -> void:
	super._ready_implementation()
	_apply_sound_settings()


const TORCH = preload("uid://cv6knp2vadwvf")

var asp_config = ASP3DConfig.new(-0.5, -0.37, 3.0, 12, 2, 0.5, BusID.GAME_SFX, TORCH)


func _apply_sound_settings():
	var asps := get_descendants.audio_stream_players_3D(self)
	if len(asps) >= 1 and play_sound:
		var _asp = asps[0]
		asp_config.set_up_asp(_asp)
		_asp.play()
