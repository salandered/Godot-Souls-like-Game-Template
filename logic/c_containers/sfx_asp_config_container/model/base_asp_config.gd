@abstract
class_name BaseASPConfig
extends RefCountedLogger

# # Linear (what we think)    →    dB (what Godot uses)
# 1.0  (100% volume)          →     0 dB
# 0.5  (50% volume)           →    -6 dB
# 0.25 (25% volume)           →   -12 dB
# 0.1  (10% volume)           →   -20 dB
# 0.01 (1% volume)            →   -40 dB
# 0.0  (silent)               →   -80 dB (or -inf)
# Formula: dB = 20 * log10(linear_value)

## increase or decrease of vol db. usually like -3 or +3
var vol_db_change: float
## increase or decrease of pitch (base pitch is always 1.0). usually like -0.2 or +0.2
var pitch_change: float
##
var max_polyphony: int
##
var bus_id: String
## may be null. client code should handle nulls
var stream: AudioStream
var from_position: float


var _min_max_vol_db_change: FMinMax = FMinMax.new(-80.0, 15.0)
var _min_max_pitch_change: FMinMax = FMinMax.new(-0.7, 0.7)
var _min_max_max_polyphony: FMinMax = FMinMax.new(1, 16)


const DEF_VOL_DB_CHANGE: float = 0.0
const DEF_PITCH_CHANGE: float = 0.0
const DEF_MAX_POLYPHONY: int = 4
const DEF_BUS_ID: String = Constants.SFX_ASP_BASE_BUS_ID


func _init(
	vol_db_change_: float = DEF_VOL_DB_CHANGE,
	pitch_change_: float = DEF_PITCH_CHANGE,
	max_polyphony_: int = DEF_MAX_POLYPHONY,
	bus_id_: String = DEF_BUS_ID,
	stream_: AudioStream = null,
	from_position_: float = 0.0
):
	self.vol_db_change = vol_db_change_
	self.pitch_change = pitch_change_
	self.max_polyphony = max_polyphony_
	self.bus_id = bus_id_
	
	self.stream = stream_
	self.from_position = from_position_

	_validate()


func _validate() -> void:
	_min_max_vol_db_change.clamp(vol_db_change, true, "vol_db_change")
	_min_max_pitch_change.clamp(pitch_change, true, "pitch_change")
	_min_max_max_polyphony.clamp(max_polyphony, true, "max_polyphony")

	if bus_id == "":
		bus_id = DEF_BUS_ID
	if not AudioServerUtil.bus_exists(bus_id):
		__log_warn_soft(pp.s("bus_id is unknown, using default", "provided/default", bus_id, DEF_BUS_ID))
		bus_id = DEF_BUS_ID

	_validate_implementation()


@abstract func _validate_implementation() -> void

## kind of abstract 
# @abstract func set_up_asp(some_asp: AudioStreamPlayer3D or AudioStreamPlayer) \
#	 -> AudioStreamPlayer3D or AudioStreamPlayer


func get_result_vol() -> float:
	return Constants.SFX_ASP_BASE_VOL_DB + vol_db_change


func get_result_pitch() -> float:
	return 1.0 + pitch_change


##

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
