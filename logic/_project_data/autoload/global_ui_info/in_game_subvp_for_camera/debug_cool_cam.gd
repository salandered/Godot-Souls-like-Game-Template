extends Camera3D
class_name DebugCoolCamera


enum CamPosMode {
	TOP,
	FRONT,
	RIGHT,
	BACK,
	LEFT,
}

@export_group("Target")
@export var target: Node3D
@export var distance_to_target: float = 8.0
@export var position_mode: CamPosMode = CamPosMode.TOP
@export var follow_rotation: bool = false


@export_group("Smoothing")
@export var enable_smoothing: bool = true
@export var smooth_speed: float = 8.0


@export_group("System")
@export var _enabled: bool = false
@export var _process_input: bool = false


var _view_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	_update_camera_transform(1.0, true)

	if projection == PROJECTION_ORTHOGONAL:
		size = distance_to_target


func _process(delta: float) -> void:
	if not _enabled: return
	
	_update_camera_transform(delta, not enable_smoothing)


func _update_camera_transform(delta: float, snap: bool = false) -> void:
	if not target: return

	var offset_vec := Vector3.ZERO
	
	match position_mode:
		CamPosMode.TOP:
			offset_vec = Vector3(0, distance_to_target, 0)
		CamPosMode.FRONT:
			offset_vec = Vector3(0, 0, distance_to_target)
		CamPosMode.BACK:
			offset_vec = Vector3(0, 0, -distance_to_target)
		CamPosMode.LEFT:
			offset_vec = Vector3(distance_to_target, 0, 0)
		CamPosMode.RIGHT:
			offset_vec = Vector3(-distance_to_target, 0, 0)

	if follow_rotation:
		offset_vec = target.global_basis * offset_vec

	var desired_position = target.global_position + offset_vec
	
	var desired_basis: Basis
	
	if position_mode == CamPosMode.TOP:
		if follow_rotation:
			var t = Transform3D(target.global_basis, target.global_position)
			t = t.rotated_local(Vector3.RIGHT, deg_to_rad(-90))
			desired_basis = t.basis
		else:
			desired_basis = Basis.from_euler(Vector3(deg_to_rad(-90), 0, 0))
	else:
		var t = Transform3D().looking_at(target.global_position - desired_position, Vector3.UP)
		desired_basis = t.basis

	var view_offset_3d = desired_basis.x * _view_offset.x + desired_basis.y * _view_offset.y
	desired_position += view_offset_3d

	if snap:
		global_position = desired_position
		global_basis = desired_basis
	else:
		global_position = global_position.lerp(desired_position, delta * smooth_speed)
		global_basis = global_basis.slerp(desired_basis, delta * smooth_speed)


func set_camera_enabled(value: bool, process_input: bool = false):
	_enabled = value
	_process_input = process_input
	# set_process_input(process_input) # switch to this


func _cycle_mode() -> void:
	position_mode = EnumUtils.cycle_sequential(CamPosMode, position_mode) as CamPosMode
	_view_offset = Vector2.ZERO


func _toggle_projection() -> void:
	if projection == PROJECTION_PERSPECTIVE:
		projection = PROJECTION_ORTHOGONAL
		size = distance_to_target # keep scale consistent
	else:
		projection = PROJECTION_PERSPECTIVE


## INPUT
# region

func _input(event: InputEvent) -> void:
	if not _enabled or not _process_input:
		return
	
	match InputUtils.get_keycode(event):
		KEY_TAB:
			_cycle_mode()
			_mark_input_handled()
		KEY_C:
			_toggle_projection()
			_mark_input_handled()
		KEY_R:
			follow_rotation = not follow_rotation
			_mark_input_handled()
		KEY_V:
			enable_smoothing = not enable_smoothing
			_mark_input_handled()
		_:
			_handle_arrow_input(event)


func _handle_arrow_input(event: InputEventKey) -> void:
	var off_change_amount = 0.5
	var dist_change_amount = 2.0
	
	if event.shift_pressed:
		# Shift: Screen-Space offsets
		if event.keycode == KEY_UP:
			_view_offset.y += off_change_amount
		elif event.keycode == KEY_DOWN:
			_view_offset.y -= off_change_amount
		elif event.keycode == KEY_LEFT:
			_view_offset.x -= off_change_amount
		elif event.keycode == KEY_RIGHT:
			_view_offset.x += off_change_amount
		_mark_input_handled()
			
	elif event.ctrl_pressed:
		if event.keycode == KEY_UP:
			fov = max(fov - 5, 10)
			if projection == PROJECTION_ORTHOGONAL: size = max(size - 1, 1)
		elif event.keycode == KEY_DOWN:
			fov = min(fov + 5, 170)
			if projection == PROJECTION_ORTHOGONAL: size = min(size + 1, 100)
		_mark_input_handled()
			
	else:
		if event.keycode == KEY_UP:
			distance_to_target += dist_change_amount
			if projection == PROJECTION_ORTHOGONAL: size = distance_to_target
			_mark_input_handled()
			
		elif event.keycode == KEY_DOWN:
			distance_to_target = max(distance_to_target - dist_change_amount, 2.0)
			if projection == PROJECTION_ORTHOGONAL: size = distance_to_target
			_mark_input_handled()

		elif event.keycode == KEY_LEFT:
			smooth_speed = max(smooth_speed - 1.0, 0.1)
			_mark_input_handled()

		elif event.keycode == KEY_RIGHT:
			smooth_speed = min(smooth_speed + 1.0, 50.0)
			_mark_input_handled()


func _mark_input_handled():
	InputUtils.mark_input_handled(self , true)

# endregion


## TEXT INFO
# region

var pos_mode_to_icon = {
	CamPosMode.TOP: "uid://d2lnia3y0gjy1",
	CamPosMode.FRONT: "uid://hx7qx6sathf1",
	CamPosMode.BACK: "uid://cixj0xwdexkia",
	CamPosMode.LEFT: "uid://bwc5cqrs5ntr4",
	CamPosMode.RIGHT: "uid://cge33vbnhyuei",
}

var projection_to_icon = {
	PROJECTION_PERSPECTIVE: "uid://bc8600hcpknd2",
	PROJECTION_ORTHOGONAL: "uid://dygwusakuflu4",
}

# Updated Text Info to display the new settings
const CONTROLS_TEXT := """[b]Arrows Up/Down[/b] - distance to target
[b]Shift + Arrows[/b] - offset
[b]Ctrl + Arrows Up/Down[/b] - FOV
[b]Tab[/b] - cycle position
[b]C[/b] - toggle Projection
[b]R[/b] - toggle Rotation Follow
[b]V[/b] - toggle Smoothing
[b]Arrows Left/Right[/b] - smooth speed
"""

func get_status_text() -> String:
	var mode_name = EnumUtils.get_name_safe(CamPosMode, position_mode)
	var proj_name = "perspective" if projection == PROJECTION_PERSPECTIVE else "orthogonal"
	var zoom_val = size if projection == PROJECTION_ORTHOGONAL else fov
	
	# Using BB.image_20_wrap if you have that utility, otherwise remove the calls
	var mode_icon = BB.image_20_wrap(pos_mode_to_icon.get(position_mode, ""))
	var projection_icon = BB.image_20_wrap(projection_to_icon.get(projection, ""))

	return pp.s(
		mode_name, mode_icon, "|", proj_name, projection_icon, "\n",
		"Dist:", distance_to_target, "| FOV:", zoom_val, "\n",
		"Smooth:", BB.b_wrap(enable_smoothing), "| speed:", smooth_speed, "\n",
		"Follow Rot:", BB.b_wrap(follow_rotation), "\n",
		"Offset:", _view_offset
	)

# endregion 
