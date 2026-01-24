extends RefCounted
class_name AudioTrackKey


var timestamp: float
## not unique! Unique to each track.
var track_idx: int
var track_enabled: bool
## example: ../SFX/AnimFS
var track_name: String
## stream.resource_name
var stream_name: String
var start_offset: float
var end_offset: float


func _init(
	timestamp_: float,
	track_idx_: int,
	track_enabled_: bool,
	track_name_: String,
	stream_name_: String,
	start_offset_: float = 0.0,
	end_offset_: float = 0.0
):
	self.timestamp = timestamp_
	self.track_idx = track_idx_
	self.track_enabled = track_enabled_
	self.track_name = track_name_
	self.stream_name = stream_name_
	self.start_offset = start_offset_
	self.end_offset = end_offset_


## '../SFX/AAnimFS' -> 'AAnimFS'
func get_anim_asp_name() -> String:
	var _r := StrUtils.get_last_slash_part(track_name)
	_r = _r.replace("$", "").replace("%", "")
	return _r


func _to_string() -> String:
	return pp.s("tiemstamp:", str(timestamp),
		"track_n", track_name,
		"stream_n", stream_name,
		"offsets", pp.in_sq(pp.s(str(start_offset), str(end_offset))))
