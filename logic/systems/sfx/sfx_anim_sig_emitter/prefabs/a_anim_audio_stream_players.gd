extends BaseNode3DSystem
class_name AAnimParent

var AA_BUS_ID := BusID.AA_MUTED
var mute_bus: bool = true # NOTE


func _ready():
	var count: int = 0
	var asps := get_descendants.audio_stream_players_3D(self)
	if not error_.empty_list(asps, "asps", WL.WARN):
		for _asp: AudioStreamPlayer3D in asps:
			if not _asp.name.begins_with(SFXConstants.anim_asp_prefix):
				__log_warn_soft("not _asp.name.begins_with(SFXConstants.anim_asp_prefix)", "AAnim init", "")
			_asp.bus = AA_BUS_ID
			count += 1

	if mute_bus:
		AudioBusUtil.mute_bus(AA_BUS_ID)
	var is_muted := AudioBusUtil.is_bus_muted(AA_BUS_ID)
	
	var _bus_mute_msg := "This bus is muted" if is_muted else pp.s(em.mark, "This bus is not muted, though")
	__log_("", "all", count, "AA ASPs set to bus ID", pp.in_q(AA_BUS_ID), "|", _bus_mute_msg)


## __LOGS
# region


func pp_name() -> String:
	return "AAnimParent🎧"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion
