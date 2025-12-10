@abstract
class_name OnSFXSigASP
extends BaseRefCountedSystem


## not nullable
var _sfx_system: BaseSFXSystem
## not nullable
var signal_data: SignalData
## not nullable
var asp: AudioStreamPlayer3D
var sfx_type: String
## not nullable
var sfx_stream_config: SFXStreamConfig


class VolPitch:
	var vol_db: float
	var pitch: float

	func _init(vol_db_: float, pitch_: float) -> void:
		vol_db = vol_db_
		pitch = pitch_

	func _to_string() -> String:
		return pp.s("vol/pitch", vol_db, pitch)
	

func get_hard_dependencies() -> Array[Object]:
	return [
		_sfx_system,
		signal_data,
		asp
	]

func get_soft_dependencies() -> Array[Object]:
	return [
		sfx_stream_config,
	]

func _init(
		sfx_system_: BaseSFXSystem,
		signal_data_: SignalData,
		asp_: AudioStreamPlayer3D,
		sfx_type_: String,
		sfx_stream_config_: SFXStreamConfig
	) -> void:
	self._sfx_system = sfx_system_
	self.signal_data = signal_data_
	self.asp = asp_
	self.sfx_type = sfx_type_
	self.sfx_stream_config = sfx_stream_config_

	if self.sfx_stream_config == null:
		__log_("no sfx_stream_config provided, using default one")
		self.sfx_stream_config = SFXStreamConfig.new(self.sfx_type)

	var validate_ok := _hard_validate_implementation()
	var deps_ok := __validate_dependencies()

	if validate_ok and deps_ok and not error_.null_signal(self.signal_data):
		__log_("connecting", self.sfx_type, "signal to callable")
		self.signal_data.signal_obj.connect(on_signal)
	else:
		__log_warn_soft("not connecting. Something wrong", "", "it is signal so gonna be fine", "")


## NOTE: args should align with signal data. In our case its payload: Dictionary
func on_signal(payload: Dictionary[String, Variant]) -> void:
	# __log_(self.sfx_type, "on_signal", "triggered")
	var base_vol_db := sfx_stream_config.base_vol_db
	var base_pitch := 1.0

	base_vol_db += sfx_stream_config.vol_db_change
	base_pitch += sfx_stream_config.pitch_change
	
	var vol_pitch := _custom_logic(base_vol_db, base_pitch, payload)
	
	__log_("result", vol_pitch)

	asp.volume_db = vol_pitch.vol_db + randf_range(-0.2, 0.2)
	asp.pitch_scale = vol_pitch.pitch + randf_range(-0.02, 0.02)
	asp.play()


## to override for additional logic
@abstract func _hard_validate_implementation() -> bool


## to override
@abstract func _custom_logic(
	base_vol_db: float,
	base_pitch: float,
	payload: Dictionary[String, Variant]
) -> VolPitch


## COMMON UTILS
# region

func _logic_random_pitch(player: AudioStreamPlayer3D, payload: Dictionary[String, Variant]) -> void:
	player.pitch_scale = player.pitch_scale + randf_range(-0.02, 0.02)


## returns "" is case of problems
func get_modifier_from_payload(payload: Dictionary[String, Variant]) -> String:
	if payload.has(SFXConstants.modifier_key):
		var modifier: Variant = payload[SFXConstants.modifier_key]
		if modifier is String:
			return modifier
	return ""


# endregion


## __LOGS
# region


func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
