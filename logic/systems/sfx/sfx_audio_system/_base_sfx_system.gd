@abstract
class_name BaseSFXSystem
extends BaseNodeSystem


## DOC
## NOTE: we call ASP - built in AudioStreamPlayer type
## e.g anim_sfx_asp_name - means name of the AudioStreamPlayer which used in anim to play sfx sounds
## Plural is ASPs or asps.
## Not the best solution, but it helps with
##   - really long names and also
##   - not overusing the word 'player'


## WARNING: should store signal_container and _on_signal_asps =>
##      - RefCounted doesn't get freed
##      - all connections keeping alive
var signal_container: BaseSignalContainer
var _on_signal_asps: Array[OnSFXSigASP]


## on init only
@abstract func _get_on_signal_asps(signals: BaseSignalContainer, sfx_configs: Dictionary[String, SFXStreamConfig]) -> Array[OnSFXSigASP]


@abstract func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void


## should be called for any sfx system
func initialise(signal_container_: BaseSignalContainer, sfx_configs: Dictionary[String, SFXStreamConfig], root_of_all_stream_players: Node, additional_data: Dictionary[String, Variant]):
	var _list := _get_on_signal_asps(signal_container_, sfx_configs)
	
	_on_signal_asps.assign(_list)
	signal_container = signal_container_
	
	initialise_implementation(additional_data)
	
	_soft_validate(root_of_all_stream_players)
	if not __validate_deps_set_init():
		__log_("__validate_deps_set_init failed, sytem won't work", "_on_signal_asps = []")
		_on_signal_asps = []


func _soft_validate(root_of_all_stream_players: Node):
	## _on_signal_asps
	var _players_total := len(_on_signal_asps)
	if _players_total == 0:
		__log_error("initialised with zero on_signal_players", "", "")
	else:
		var _all_sfx_types: Array[String] = []
		for item: OnSFXSigASP in _on_signal_asps:
			_all_sfx_types.append(item.sfx_type)
		__log_("validation", "we have", _players_total, "on_signal_players:", pp.list_(_all_sfx_types))


	## all_stream_players
	__log_("validation", "using root for all stream players", root_of_all_stream_players, root_of_all_stream_players.name)
	
	var skip_subscenes := false # not sure
	var all_stream_players := get_descendants.audio_stream_players_3D(root_of_all_stream_players, skip_subscenes)
	if len(all_stream_players) == 0:
		__log_error("no all_stream_players. That is odd", "validation", "")
	else:
		for _asp: AudioStreamPlayer3D in all_stream_players:
			if not _asp.name.begins_with(SFXConstants.anim_asp_prefix) \
				and _asp.stream == null:
				__log_error("no stream for AudioStreamPlayer3D", "validation", "", _asp, _asp.name)


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
