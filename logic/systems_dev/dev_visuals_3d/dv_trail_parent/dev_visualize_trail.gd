@tool
class_name DevVisualizeTrail
extends BaseDevVisualizeParent


@export_group("Visuals")
@export var color_mode: ColorMode = ColorMode.SINE_WAVE
@export var path_color_a := Color.ORANGE
@export var path_color_b := Color.RED
@export var trail_radius := 0.03
@export var trail_duration := 2.0
@export var fade_duration := 0.25
@export var cast_shadow: GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
@export var shading_mode: BaseMaterial3D.ShadingMode = BaseMaterial3D.SHADING_MODE_UNSHADED


@export_group("Performance")
## how many cylinders we have in pool
@export var trail_segments := 20
## time in seconds between creating new segments 
## 0.0 = every frame
## 0.1 = 10 times per second
@export var update_interval_seconds := 0.025
## If distance exceeds this, trail will break, not stretch
@export var max_segment_length := 5.0

## if color_mode SINE_WAVE
@export_subgroup("Sine Settings")
@export var color_cycle_speed := 5.0

## if color_mode VELOCITY
@export_subgroup("Velocity Settings")
@export var min_velocity := 0.0
@export var max_velocity := 10.0


enum ColorMode {SINE_WAVE, VELOCITY}


var _curr_position := Vector3.INF
var _last_spawn_position := Vector3.INF
var _time_since_last_spawn := 0.0

var _cylinders: Array[MeshInstance3D] = []
var _cylinder_creation_times: Array[float] = []
var _cylinder_head_idx := 0


func _initialize_implementation_both_editor_and_game() -> void:
	super._initialize_implementation_both_editor_and_game()
	_init_cylinder_pool()


func _init_cylinder_pool() -> void:
	for c in _cylinders:
		if is_instance_valid(c):
			c.queue_free()
	_cylinders.clear()
	_cylinder_creation_times.clear()
	
	_cylinder_creation_times.resize(trail_segments)
	_cylinder_creation_times.fill(0.0)

	for i in range(trail_segments):
		var mi := MeshInstanceUtils.create_generic_cylinder(
			trail_radius,
			cast_shadow,
			shading_mode,
			true
		)
		
		mi.top_level = true
		mi.visible = false
		
		add_child(mi)
		_cylinders.append(mi)


func reset_visuals() -> void:
	_curr_position = Vector3.INF
	_last_spawn_position = Vector3.INF
	_time_since_last_spawn = 0.0

	_cylinder_head_idx = 0
	_cylinder_creation_times.fill(0.0)

	for mi in _cylinders:
		if is_instance_valid(mi):
			mi.visible = false


func _conditions_to_visualize() -> bool:
	return true


func _process_before_visalisation(delta: float) -> void:
	if not is_instance_valid(_parent_node):
		return
	_curr_position = _parent_node.global_position
	_update_segment_opacity()


func _process_visualization(delta: float) -> void:
	if _curr_position == Vector3.INF:
		return

	if _last_spawn_position == Vector3.INF:
		_last_spawn_position = _curr_position
		return

	_time_since_last_spawn += delta
	if _time_since_last_spawn < update_interval_seconds:
		return

	var dist_sq := _last_spawn_position.distance_squared_to(_curr_position)
	
	# skip if minimal movement
	if dist_sq < 0.00001:
		return
		
	# teleport check
	if dist_sq > (max_segment_length * max_segment_length):
		_last_spawn_position = _curr_position
		_time_since_last_spawn = 0.0
		return

	_time_since_last_spawn = 0.0
	
	var current_color := _calculate_trail_color(delta, dist_sq)
	_place_next_cylinder_segment(_last_spawn_position, _curr_position, current_color)
	
	_last_spawn_position = _curr_position


func _calculate_trail_color(delta: float, dist_sq: float) -> Color:
	var t: float = 0.0
	
	if color_mode == ColorMode.SINE_WAVE:
		t = (sin(_time_elapsed * color_cycle_speed) + 1.0) / 2.0
		
	elif color_mode == ColorMode.VELOCITY:
		var time_div := maxf(update_interval_seconds, delta)
		var actual_speed := sqrt(dist_sq) / maxf(time_div, 0.00001)
		t = clampf(inverse_lerp(min_velocity, max_velocity, actual_speed), 0.0, 1.0)
	
	return path_color_a.lerp(path_color_b, t)


func _place_next_cylinder_segment(pos_a: Vector3, pos_b: Vector3, color: Color) -> void:
	if _cylinders.is_empty():
		return

	var idx := _cylinder_head_idx
	var mi := _cylinders[idx]
	
	_cylinder_head_idx = (_cylinder_head_idx + 1) % _cylinders.size()
	_cylinder_creation_times[idx] = _time_elapsed

	MeshInstanceUtils.place_cylinder_between(mi, pos_a, pos_b, color)


func _update_segment_opacity() -> void:
	if trail_duration <= 0.0:
		return
		
	var safe_fade_duration := maxf(fade_duration, 0.001)
	var start_fade_time := trail_duration - safe_fade_duration
	
	for i in range(_cylinders.size()):
		var mi := _cylinders[i]
		if not mi.visible:
			continue
			
		var age := _time_elapsed - _cylinder_creation_times[i]
		
		if age >= trail_duration:
			mi.visible = false
		elif age > start_fade_time:
			var fade_progress := (age - start_fade_time) / safe_fade_duration
			var mat := mi.material_override as StandardMaterial3D
			if mat:
				var col := mat.albedo_color
				col.a = 1.0 - fade_progress
				mat.albedo_color = col
