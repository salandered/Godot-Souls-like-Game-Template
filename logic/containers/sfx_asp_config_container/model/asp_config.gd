extends BaseASPConfig
class_name ASPConfig


# TODO: var mix_target: int
## has effect if > 0.0

## Template to quickly initialize new config
# var asp_config := ASPConfig.new(
# 	ASPConfig.DEF_VOL_DB_CHANGE,
# 	ASPConfig.DEF_PITCH_CHANGE,
# 	ASPConfig.DEF_MAX_POLYPHONY,
# 	ASPConfig.DEF_BUS_ID,
# 	null)


func _init(
	vol_db_change_: float = DEF_VOL_DB_CHANGE,
	pitch_change_: float = DEF_PITCH_CHANGE,
	max_polyphony_: int = DEF_MAX_POLYPHONY,
	bus_id_: StringName = DEF_BUS_ID,
	stream_: AudioStream = null,
	from_position_: float = 0.0
):
	super._init(vol_db_change_, pitch_change_, max_polyphony_, bus_id_, stream_, from_position_)


func _validate_implementation() -> void:
	pass


func set_up_asp(some_asp: AudioStreamPlayer) -> AudioStreamPlayer:
	if not some_asp: return null
	
	some_asp.volume_db = Const.SFX_ASP_BASE_VOL_DB
	some_asp.volume_db += vol_db_change

	some_asp.pitch_scale = 1.0
	some_asp.pitch_scale += pitch_change

	some_asp.max_polyphony = max_polyphony

	some_asp.bus = bus_id

	## prevents erasing stream if config's stream is null and some_asp's already has its own
	if stream:
		some_asp.stream = stream
	
	return some_asp


func _to_string() -> String:
	return pp.s("Vol/Pitch changes/MaxPolyph", vol_db_change, pitch_change, max_polyphony,
		pp.bus_id(bus_id), "Stream", str(stream) if stream else "[-]", "from_pos", from_position)
