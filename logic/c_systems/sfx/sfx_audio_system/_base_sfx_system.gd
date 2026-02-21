@abstract
class_name BaseSFXSystem
extends NodeSystem


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
## may return any number of objects. Stores as is. No property ID needed.
# region: DOCS
##
## Example with basic character footstep handler.
# OnCharFSSigASP.new(
# 	self,
# 	sig_container.get_by_sig_id(SignalID.sfx_footstep),
# 	get_fs_asp_3d(),
# 	asp_config_container.get_by_sfx_type_id(SFXConstants.ID_.footstep)
# ),
## Example of changes:
## 	    - change asp_3d, then on fs signal another ASP will be playing with its own streams. 
##        so one signal -> two sounds
## 
@abstract func _get_on_signal_asps(signals: BaseSignalContainer, asp_config_container: BaseSFXASPConfigContainer) -> Array[OnSFXSigASP]


@abstract func initialise_implementation(additional_data: Dictionary[StringName, Variant]) -> void


## should be called for any sfx system
func initialise(
		signal_container_: BaseSignalContainer,
		asp_config_container: BaseSFXASPConfigContainer,
		root_of_asps: Node,
		additional_data: Dictionary[StringName, Variant]
	) -> void:
	initialise_implementation(additional_data)
	
	var _list := _get_on_signal_asps(signal_container_, asp_config_container)
	
	self ._on_signal_asps.assign(_list)
	self .signal_container = signal_container_
	
	
	_soft_validate_asps(root_of_asps)

	_soft_validate_on_signal_asps()


	if not __perform_validation():
		__log_warn_soft("__perform_validation failed, sytem won't work", "_on_signal_asps = []")
		_on_signal_asps = []
	else:
		__log_("", "initialised")


func _soft_validate_on_signal_asps():
	var _players_total := len(_on_signal_asps)
	if not error_.empty_list(_on_signal_asps, "_on_signal_asps", WL.WARN):
		var _all_sfx_types: Array[StringName] = []
		for item: OnSFXSigASP in _on_signal_asps:
			_all_sfx_types.append(item.asp.name)
		__log_("validation", "we have", len(_on_signal_asps), "on_signal_players:", pp.list_(_all_sfx_types))


func _soft_validate_asps(root_of_asps: Node):
	__log_("validation", "using root_of_asps", root_of_asps.name)
	
	var skip_subscenes := false # not sure
	var asps := get_descendants.audio_stream_players_3D(root_of_asps, skip_subscenes)
	if not error_.empty_list(asps, "asps"):
		for _asp: AudioStreamPlayer3D in asps:
			if not _asp.name.begins_with(SFXConstants.anim_asp_prefix):
				error_.null_object(_asp.stream, pp.s("no stream for AudioStreamPlayer3D", _asp.name))

##


func disable():
	var count := 0
	for item in _on_signal_asps:
		count += 1
		item.disable()
	__log_(em.pin, "disabled all", count, "_on_signal_asps")

func enable():
	var count := 0
	for item in _on_signal_asps:
		count += 1
		item.enable()
	__log_(em.pin, "enabled all", count, "_on_signal_asps")

## __LOG


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0
