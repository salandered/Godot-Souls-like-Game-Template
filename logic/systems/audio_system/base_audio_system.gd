@abstract
class_name BaseAudioSystem
extends BaseNodeSystem


## WARNING: should store _signals and _on_signal_players =>
##      - RefCounted doesn't get freed
##      - all connections keeping alive
var _signals: BaseSignals
var _on_signal_players: Array[OnSFXSignalPlayer]


@abstract func create_on_signal_players(signals: BaseSignals) -> Array[OnSFXSignalPlayer]


@abstract func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void


## should be called for any audio system
func initialise(signals: BaseSignals, root_of_all_stream_players: Node, additional_data: Dictionary[String, Variant]):
	var on_signal_players_ := create_on_signal_players(signals)
	

	_on_signal_players.assign(on_signal_players_)
	_signals = signals
	
	initialise_implementation(additional_data)
	
	_validate(root_of_all_stream_players)


func _validate(root_of_all_stream_players: Node):
	## _on_signal_players
	var _players_total := len(_on_signal_players)
	if _players_total == 0:
		__log_warn(true, "initialised with zero on_signal_players", "", "")
	else:
		var _all_descriptions = []
		for item: OnSFXSignalPlayer in _on_signal_players:
			_all_descriptions.append(item._description)
		__log_("validation", "we have", _players_total, "on_signal_players:", pp.list_(_all_descriptions))


	## all_stream_players
	__log_("validation", "using root for all stream players", root_of_all_stream_players, root_of_all_stream_players.name)
	
	var skip_subscenes = false # not sure
	var all_stream_players := get_descendants.audio_stream_players_3D(root_of_all_stream_players, skip_subscenes)
	if len(all_stream_players) == 0:
		__log_warn(true, "no all_stream_players. That is odd", "validation", "")
	else:
		for _stream_player: AudioStreamPlayer3D in all_stream_players:
			if not _stream_player.name.begins_with(SfxType.anim_stream_player_prefix) \
				and _stream_player.stream == null:
				__log_warn(true, "no stream for AudioStreamPlayer3D", "validation", "", _stream_player, _stream_player.name)


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
