@abstract
class_name OnSFXSigASP
extends RefCountedLogger


var _sfx_system: BaseSFXSystem
var signal_: Signal
var asp: AudioStreamPlayer3D
var _description: String


func _init(
		sfx_system_: BaseSFXSystem,
		signal_data_: SignalData,
		asp_: AudioStreamPlayer3D,
		description_: String,
	) -> void:
	if not sfx_system_:
		__log_error(pp.s("no", description_, "sfx_system_", "very strange"), "", "skipping connection")
		return
	if not signal_data_:
		__log_error(pp.s("no", description_, "signal_data_"), "", "skipping connection")
		return
	if not asp_:
		__log_error(pp.s("no", description_, "asp"), "", "skipping connection")
		return
	
	self._description = description_
	self._sfx_system = sfx_system_
	self.signal_ = signal_data_.signal_obj
	self.asp = asp_


	__log_("connecting", self._description, "signal to callable")
	self.signal_.connect(on_signal)

	_validate()


## NOTE: should align with signal data. In our case its data: Dictionary
func on_signal(signal_data: Dictionary[String, Variant]) -> void:
	# __log_(self._description, "on_signal", "triggered")
	_custom_logic(signal_data)
	self.asp.play()


## to override for additional logic
@abstract func _validate()


## to override
@abstract func _custom_logic(signal_data: Dictionary[String, Variant]) -> void


## COMMON UTILS
# region

func _logic_random_pitch(player: AudioStreamPlayer3D, signal_data: Dictionary[String, Variant]) -> void:
	player.pitch_scale = player.pitch_scale + randf_range(-0.02, 0.02)

# endregion


## __LOGS
# region


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
