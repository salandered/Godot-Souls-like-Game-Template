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
var asp_config: ASP3DConfig


var __disabled: bool = false

var _log_tag: String = ""

class VolPitch:
	var vol_db: float
	var pitch: float
	var mute: bool = false
	var from_position: float = 0.0

	func _init(vol_db_: float, pitch_: float, mute_: bool = false, from_position_: float = 0.0) -> void:
		self.vol_db = vol_db_
		self.pitch = pitch_
		self.mute = mute_
		self.from_position = from_position_

	func _to_string() -> String:
		return pp.s("vol/pitch/mute/from_pos", vol_db, pitch, mute, from_position)
	

func __hard_dependencies() -> Array:
	return [
		_sfx_system,
		signal_data,
		asp
	]

func __soft_dependencies() -> Array:
	return [
		asp_config,
	]

func _init(
		sfx_system_: BaseSFXSystem,
		signal_data_: SignalData,
		asp_: AudioStreamPlayer3D,
		asp_config_: ASP3DConfig,
		log_tag_: String = ""
	) -> void:
	self._log_tag = log_tag_


	self._sfx_system = sfx_system_
	self.signal_data = signal_data_
	self.asp = asp_
	self.asp_config = asp_config_


	if self.asp_config == null:
		__log_("no asp_config provided, using default one")
		self.asp_config = ASP3DConfig.new()

	self.asp = self.asp_config.set_up_asp(self.asp)

	var validate_ok := _hard_validate_implementation()
	var deps_ok := __perform_validation()

	if validate_ok and deps_ok and not error_.null_signal(self.signal_data.signal_obj):
		__log_("init ok", "connecting signal", "stream", asp.stream)
		self.signal_data.signal_obj.connect(on_signal)
	else:
		__log_warn_soft("not connecting. Something wrong", "", "it is signal so gonna be fine", "")


## NOTE: args should align with signal data. In our case its payload: Dictionary
func on_signal(payload: Dictionary[StringName, Variant]) -> void:
	if __disabled:
		return
	# __log_(self.sfx_type, "on_signal", "triggered")
	## dynamic values are reset on every on_signal
	var base_vol_db := Const.SFX_ASP_BASE_VOL_DB
	var base_pitch := 1.0

	base_vol_db += asp_config.vol_db_change
	base_pitch += asp_config.pitch_change
	
	var vol_pitch := _custom_logic(base_vol_db, base_pitch, payload)
	
	asp.volume_db = vol_pitch.vol_db + randf_range(-0.2, 0.2)
	asp.pitch_scale = vol_pitch.pitch + randf_range(-0.02, 0.02)
	
	if not vol_pitch.mute:
		_asp_play(vol_pitch)


func _asp_play(vol_pitch: VolPitch):
	var r_from_pos := asp_config.from_position if vol_pitch.from_position == 0.0 else vol_pitch.from_position
	asp.play(r_from_pos)
	# __log_(pp.s(asp.name, "🎵"), pp.asp_3d_play(asp), "from_pos", r_from_pos)


## to override for additional logic
@abstract func _hard_validate_implementation() -> bool


## 
## given base_vol_db and base_pitch, aligned with the asp_config
@abstract func _custom_logic(
	base_vol_db: float,
	base_pitch: float,
	payload: Dictionary[StringName, Variant]
) -> VolPitch


func _get_log_tag() -> String:
	return _log_tag

## COMMON UTILS
# region

func _logic_random_pitch(player: AudioStreamPlayer3D, payload: Dictionary[StringName, Variant]) -> void:
	player.pitch_scale = player.pitch_scale + randf_range(-0.02, 0.02)


## returns "" is case of problems
func get_modifier_from_payload(payload: Dictionary[StringName, Variant]) -> StringName:
	return _get_key_from_payload(SFXConstants.modifier_key, payload)

## returns "" is case of problems
func get_unique_from_payload(payload: Dictionary[StringName, Variant]) -> StringName:
	return _get_key_from_payload(SFXConstants.unique_key, payload)

## returns "" is case of problems
func get_weapon_id_from_payload(payload: Dictionary[StringName, Variant]) -> StringName:
	return _get_key_from_payload(SFXConstants.weapon_id_key, payload)

func _get_key_from_payload(key: StringName, payload: Dictionary[StringName, Variant]) -> StringName:
	if payload.has(key):
		var modifier: Variant = payload[key]
		if modifier is StringName:
			return modifier
	return Const.EMPTY_SNAME


# endregion

##

func enable():
	__disabled = false


func disable():
	__disabled = true


## __LOGS
# region


func pp_name() -> String:
	return pp.s(ObjUtils.construct_obj_pp_name(self ), _get_log_tag(), pp.bus_id(asp.bus))


func __LOG_INDENT() -> int:
	return 2

# endregion
