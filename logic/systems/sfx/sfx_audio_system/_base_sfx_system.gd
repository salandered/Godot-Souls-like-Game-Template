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
@abstract func _get_on_signal_asps(signals: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]


@abstract func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void


## should be called for any sfx system
func initialise(
		signal_container_: BaseSignalContainer,
		asp_config_container: BaseSFXASPConfigContainer,
		root_of_asps: Node,
		audio_bus_id: String,
		additional_data: Dictionary[String, Variant]
	) -> void:
	var _list := _get_on_signal_asps(signal_container_, asp_config_container)
	
	_on_signal_asps.assign(_list)
	signal_container = signal_container_
	
	initialise_implementation(additional_data)
	
	_set_audio_bus_id(root_of_asps, audio_bus_id)

	_soft_validate_on_signal_asps()


	if not __validate_deps_set_init():
		__log_warn_soft("__validate_deps_set_init failed, sytem won't work", "_on_signal_asps = []")
		_on_signal_asps = []
	else:
		__log_("", "initialised. auido bus id:", audio_bus_id)


func _soft_validate_on_signal_asps():
	var _players_total := len(_on_signal_asps)
	if not error_.empty_list(_on_signal_asps, "_on_signal_asps", WL.WARN):
		var _all_sfx_types: Array[String] = []
		for item: OnSFXSigASP in _on_signal_asps:
			_all_sfx_types.append(item.sfx_type)
		__log_("validation", "we have", len(_on_signal_asps), "on_signal_players:", pp.list_(_all_sfx_types))


func _set_audio_bus_id(root_of_asps: Node, audio_bus_id: String):
	__log_("validation", "using root_of_asps", root_of_asps.name)
	
	var skip_subscenes := false # not sure
	var asps := get_descendants.audio_stream_players_3D(root_of_asps, skip_subscenes)
	if not error_.empty_list(asps, "asps"):
		for _asp: AudioStreamPlayer3D in asps:
			if not _asp.name.begins_with(SFXConstants.anim_asp_prefix):
				if not error_.null_object(_asp.stream, pp.s("no stream for AudioStreamPlayer3D", _asp.name)):
					_asp.bus = audio_bus_id


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
