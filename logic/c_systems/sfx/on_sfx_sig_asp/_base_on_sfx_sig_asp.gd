@abstract
class_name OnSFXSigASP
extends RefCountedSystem


## not nullable
var _sfx_system: BaseSFXSystem
## not nullable
var signal_data: SignalData
## not nullable
var asp: AudioStreamPlayer3D
## not nullable
var asp_config: ASPConfig


var _log_tag: String = ""

class VolPitch:
	var vol_db: float
	var pitch: float
	var mute: bool = false

	func _init(vol_db_: float, pitch_: float, mute_: bool = false) -> void:
		self.vol_db = vol_db_
		self.pitch = pitch_
		self.mute = mute_

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
		asp_config,
	]

func _init(
		sfx_system_: BaseSFXSystem,
		signal_data_: SignalData,
		asp_: AudioStreamPlayer3D,
		asp_config_: ASPConfig,
		log_tag_: String = ""
	) -> void:
	self._log_tag = log_tag_


	self._sfx_system = sfx_system_
	self.signal_data = signal_data_
	self.asp = asp_
	self.asp_config = asp_config_


	if self.asp_config == null:
		__log_("no asp_config provided, using default one")
		self.asp_config = ASPConfig.new()

	self.asp = self.asp_config.set_up_asp(self.asp)

	var validate_ok := _hard_validate_implementation()
	var deps_ok := __validate_dependencies()

	if validate_ok and deps_ok and not error_.null_signal(self.signal_data):
		__log_("init ok", "connecting signal", "stream", asp.stream)
		self.signal_data.signal_obj.connect(on_signal)
	else:
		__log_warn_soft("not connecting. Something wrong", "", "it is signal so gonna be fine", "")


## NOTE: args should align with signal data. In our case its payload: Dictionary
func on_signal(payload: Dictionary[String, Variant]) -> void:
	# __log_(self.sfx_type, "on_signal", "triggered")
	## dynamic values are reset on every on_signal
	var base_vol_db := Constants.SFX_ASP_BASE_VOL_DB
	var base_pitch := 1.0

	base_vol_db += asp_config.vol_db_change
	base_pitch += asp_config.pitch_change
	
	var vol_pitch := _custom_logic(base_vol_db, base_pitch, payload)
	
	asp.volume_db = vol_pitch.vol_db + randf_range(-0.2, 0.2)
	asp.pitch_scale = vol_pitch.pitch + randf_range(-0.02, 0.02)
	
	if not vol_pitch.mute:
		_asp_play()


func _asp_play():
	asp.play()
	# __log_(pp.s(asp.name, "🎵"), pp.asp_play(asp))


## to override for additional logic
@abstract func _hard_validate_implementation() -> bool


## 
## given base_vol_db and base_pitch, aligned with the asp_config
@abstract func _custom_logic(
	base_vol_db: float,
	base_pitch: float,
	payload: Dictionary[String, Variant]
) -> VolPitch


func _get_log_tag() -> String:
	return _log_tag

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

## returns "" is case of problems
func get_unique_from_payload(payload: Dictionary[String, Variant]) -> String:
	if payload.has(SFXConstants.unique_key):
		var modifier: Variant = payload[SFXConstants.unique_key]
		if modifier is String:
			return modifier
	return ""


# endregion


## __LOGS
# region


func pp_name() -> String:
	return pp.s(u.construct_obj_pp_name(self), _get_log_tag(), pp.bus_id(asp.bus))


func __LOG_INDENT() -> int:
	return 2

# endregion
