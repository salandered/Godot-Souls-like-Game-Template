extends RefCounted
class_name AudioTrackData


var timestamp: float
## example: ../SFX/AnimFS
var track_name: String
## example: concr_footsteps_pack_1
var stream_name: String
var start_offset: float
var end_offset: float


func _init(
	timestamp_: float,
	track_name_: String,
	stream_name_: String,
	start_offset_: float = 0.0,
	end_offset_: float = 0.0
):
	timestamp = timestamp_
	track_name = track_name_
	stream_name = stream_name_
	start_offset = start_offset_
	end_offset = end_offset_


## '../SFX/AnimFS' -> 'AnimFS'
func get_audio_stream_player_name() -> String:
	var _r := u.get_last_slash_part(track_name)
	_r = _r.replace("$", "").replace("%", "")
	return _r


func _to_string() -> String:
	return pp.s("tiemstamp:", str(timestamp),
		"track_n", track_name,
		"stream_n", stream_name,
		"offsets", pp.in_sq(pp.s(str(start_offset), str(end_offset))))
