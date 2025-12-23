@abstract
class_name BaseRigidBodyPhysicsSFX
extends RigidBody3DLogger


const _ASP_3D_NAME := "RigidBodyASP3D"


const DEFAULT_IMPACT_STREAM: AudioStream = preload("uid://de0vjaija8veh")

var _sfx_asp: AudioStreamPlayer3D
var _previous_velocity: Vector3 = Vector3.ZERO
var _base_volume_db: float

var _last_sound_time: float = 0.0


var IMPACT_THRESHOLD: float = 0.6 # Minimum impact force to play sound
var SOUND_COOLDOWN: float = 0.1
var MAX_CONTACTS_REPORTED := 4


## config. can be overridden
func get_impact_threshold() -> float:
	return IMPACT_THRESHOLD


func get_sound_cooldown() -> float:
	return SOUND_COOLDOWN

func get_max_contacts_reported_() -> int:
	return MAX_CONTACTS_REPORTED
##

func _ready():
	_find_asp()
	_initialise_asp()
	_initialise_coll_layer()

	contact_monitor = true
	max_contacts_reported = get_max_contacts_reported_()
	body_entered.connect(_on_body_entered)

	initialise_implementation()


func _find_asp():
	var asps := get_descendants.audio_stream_players_3D(self)
	for item: AudioStreamPlayer3D in asps:
		if item.name == _ASP_3D_NAME:
			_sfx_asp = item
			__log_("_find_asp", "found existing ASP in tree")
			return

	# not found asp in tree
	if not _sfx_asp:
		__log_("_find_asp", "creating new ASP node")
		_sfx_asp = AudioStreamPlayer3D.new()
		_sfx_asp.name = _ASP_3D_NAME
		self.add_child(_sfx_asp)


func _initialise_asp():
	var asp_config = get_asp_config()
	if asp_config == null:
		__log_("no asp_config provided, using default one")
		asp_config = ASP3DConfig.new()
	
	asp_config.set_up_asp(_sfx_asp)
	if _sfx_asp.stream == null:
		__log_("", "_sfx_asp.stream == null, using default")
		_sfx_asp.stream = DEFAULT_IMPACT_STREAM
	_base_volume_db = _sfx_asp.volume_db

	__log_("_initialise_asp", "using config", asp_config, "stream is", str(_sfx_asp.stream) if _sfx_asp.stream else "[-]")


## base layer for RigidBody. Implementation may override if needed
func _initialise_coll_layer():
	collision_layer = Collision.Layers.ITEM_COL
	collision_mask = Collision.Masks.ITEM_COL_MASK


@abstract func get_asp_config() -> ASP3DConfig

@abstract func initialise_implementation() -> void


func _physics_process(_delta):
	_previous_velocity = linear_velocity
	if global_position.y < -50:
		self.queue_free()


func _on_body_entered(_body):
	var velocity_change = _previous_velocity - linear_velocity
	var impact_force = velocity_change.length()
	__log_("", "impact_force vel_change/prev_vel/linear_vel", impact_force, velocity_change, _previous_velocity, linear_velocity)
	
	var current_time = u.get_curr_time_ticks_sec()
	if impact_force > get_impact_threshold() and (current_time -_last_sound_time) > get_sound_cooldown():
		# scale volume by impact force
		var volume = remap(impact_force, get_impact_threshold(), get_impact_threshold() * 3, 0.5, 1.0)
		var impact_db_adjustment = linear_to_db(clamp(volume, 0.0, 1.0))
		_sfx_asp.volume_db = _base_volume_db + impact_db_adjustment
		
		__log_("impact sound", "force", impact_force, "final_vol_db", _sfx_asp.volume_db, "adjustment", impact_db_adjustment)
		_sfx_asp.play()
		__log_(pp.s(_sfx_asp.name, "🎵"), pp.asp_3d_play(_sfx_asp))
		_last_sound_time = current_time


# # Linear (what we think)    →    dB (what Godot uses)
# 1.0  (100% volume)          →     0 dB
# 0.5  (50% volume)           →    -6 dB
# 0.25 (25% volume)           →   -12 dB
# 0.1  (10% volume)           →   -20 dB
# 0.01 (1% volume)            →   -40 dB
# 0.0  (silent)               →   -80 dB (or -inf)
# Formula: dB = 20 * log10(linear_value)


## __LOGS
# region


func __LOG_INDENT() -> int:
	return 0

# endregion
