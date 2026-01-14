@tool
class_name SwayParent
extends NodeLogger


@export_group("Sway Settings")
@export var ENABLED: bool = true
@export var max_sway_degrees: float = 5.0:
	set(value):
		max_sway_degrees = value
@export var sway_speed: float = 2.0:
	set(value):
		sway_speed = value
@export var phase_offset: float = 0.0


@export_group("Audio Settings")
@export var audio_stream: AudioStream
@export_range(-80, 10, 1) var volume_db_change: float = 0.0
@export_range(-1.0, 1.0, 0.1) var pitch_scale_change: float = 0.0
@export var max_distance: float = 10.0
@export var unit_size: float = 5.0
## chance to play when condition met
@export_range(0.0, 1.0) var play_chance: float = 0.3
## Seconds between potential sounds
@export var min_interval: float = 5.0

@export_group("Editor")
@export var preview_in_editor: bool = false: set = _set_preview

var _start_rot: Vector3 = Vector3.ZERO

var _parent_node: Node3D
var _asp: AudioStreamPlayer3D
var _time: float = 0.0


var _last_sound_cooldown: Cooldown

func _ready() -> void:
	var parent := get_parent()
	if parent is Node3D:
		_parent_node = parent
		_start_rot = _parent_node.rotation_degrees
	else:
		__log_("Parent is not a Node3D", "", "won't be working")
		set_process(false)
		return


	if not Engine.is_editor_hint():
		## randf_range randomise starting point
		_time = randf_range(0.0, 100.0) + phase_offset

		_setup_audio()


func _setup_audio() -> void:
	if not audio_stream:
		return
	
	_last_sound_cooldown = Cooldown.new(min_interval)
		
	_asp = AudioStreamPlayer3D.new()
	_parent_node.add_child.call_deferred(_asp)
	
	var _asp_config := ASP3DConfig.new(
		volume_db_change,
		pitch_scale_change,
		unit_size,
		max_distance,
		2,
		0.5,
		ASP3DConfig.DEF_BUS_ID,
		audio_stream
	)
	_asp_config.set_up_asp(_asp)


func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview_in_editor:
		return
	
	if not ENABLED or not _parent_node or _parent_node.is_queued_for_deletion():
		return

	_apply_sway(delta)
	
	if not Engine.is_editor_hint():
		_handle_audio_logic(delta)


func _apply_sway(delta: float) -> void:
	_time += delta * sway_speed
	
	var z_rot := sin(_time) * max_sway_degrees
	var x_rot := cos(_time * 0.7) * (max_sway_degrees * 0.25)
	
	_parent_node.rotation_degrees.x = _start_rot.x + x_rot
	_parent_node.rotation_degrees.z = _start_rot.z + z_rot

func _handle_audio_logic(delta: float) -> void:
	if not _asp or not _asp.stream or not _last_sound_cooldown:
		return

	if not _last_sound_cooldown.is_cooldown_passed():
		return
		
	# Only try to play when sway is near its peak (changing direction)
	# sin(x) is near peak (1 or -1) when cos(x) is near 0
	var sway_momentum := cos(_time)

	if abs(sway_momentum) < 0.1: # Near the "turn around" point of the swing
		_last_sound_cooldown.mark_time()
		if randf() < play_chance:
			_play_creak()
		

func _play_creak() -> void:
	# __log_("_play_creak")
	if _asp and not _asp.playing:
		# __log_("_play_creak inside")
		# vary pitch slightly
		_asp.pitch_scale = (1.0 + pitch_scale_change) + randf_range(-0.1, 0.1)
		_asp.play()


## export setters

func _set_preview(value: bool) -> void:
	if value and not preview_in_editor and _parent_node:
		_start_rot = _parent_node.rotation_degrees

	preview_in_editor = value
	
	if not preview_in_editor and _parent_node and Engine.is_editor_hint():
		_parent_node.rotation_degrees = _start_rot

##

func _exit_tree() -> void:
	if _parent_node and Engine.is_editor_hint():
		_parent_node.rotation_degrees = _start_rot
