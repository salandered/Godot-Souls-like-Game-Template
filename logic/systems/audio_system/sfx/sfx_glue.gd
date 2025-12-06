extends RefCounted
class_name SFXGlue


var type_name: String
## should follow names located in scene tree SFX/ (see Player scene)
var anim_audio_stream_player_name: String


func _init(type_name_: String, anim_audio_stream_player_name_: String) -> void:
	type_name = type_name_
	anim_audio_stream_player_name = anim_audio_stream_player_name_
