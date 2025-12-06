@abstract
class_name OnSFXSignalPlayer
extends RefCountedLogger


var _audio_system: BaseAudioSystem
var signal_: Signal
var stream_player: AudioStreamPlayer3D
var _description: String


func _init(
		audio_system: BaseAudioSystem,
		signal__: Signal,
		stream_player_: AudioStreamPlayer3D,
		description_: String,
	) -> void:
	self._audio_system = audio_system
	self.signal_ = signal__
	self.stream_player = stream_player_
	self._description = description_

	if not self.stream_player:
		__log_warn(false, pp.s("no", self._description, "stream_player"), "", "will be no sound")
		return
	if not self.signal_:
		__log_warn(false, pp.s("no", self._description, "signal"), "", "skipping connection")
		return
	
	__log_("connecting", self._description, "signal to callable")
	self.signal_.connect(on_signal)

	_validate()

## NOTE: should align with signal data. In out case its data: Dictionary
func on_signal(signal_data: Dictionary[String, Variant]) -> void:
	# __log_(self._description, "on_signal", "triggered")
	if self.stream_player:
		_custom_logic(signal_data)
		self.stream_player.play()


## to override
@abstract func _validate()


## to override
@abstract func _custom_logic(signal_data: Dictionary) -> void


## COMMON UTILS
# region

func _logic_random_pitch(player: AudioStreamPlayer3D, signal_data: Dictionary) -> void:
	player.pitch_scale = player.pitch_scale + randf_range(-0.02, 0.02)

# endregion


## __LOGS
# region


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
