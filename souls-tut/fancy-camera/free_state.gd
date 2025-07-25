extends CameraState
class_name FreeCameraState

@onready var root_player: CharacterBody3D = $"../.."
@onready var fancy_camera: FancyCamera = $".."
@onready var focus_point: Node3D = %FocusPoint
@onready var camera_nest: Node3D = %CameraNest
@onready var camera_mount: Node3D = %CameraMount
@onready var camera: Camera3D = %PlayerCamera
@onready var locked_camera: LockedCameraState = %LockedCamera

const TARGET_DROP_DISTANCE_SQUARED = 64

var look_at_: Node3D
var offset: Vector3

@export var hor_sense: float = 1.0
@export var ver_sense: float = 1.0

@export var min_vertical_angle: float = 0.62
@export var max_vertical_angle: float = 1.87

@export var follow_speed: float = 0.05
@export var lerp_speed: float = 8.0

func _ready():
	offset = camera_nest.global_position - camera_mount.global_position
	look_at_ = fancy_camera.look_at_
	print("FreeCameraState ready()")
	print("		root_player ", root_player)
	print("		look_at_ ", look_at_)
	print("		offset ", offset)


func update(delta: float):
	_move_focus_point()
	_move_camera_mount()
	_move_camera(delta)


func _move_focus_point() -> void:
	var camera_focus_position := look_at_.global_position # look_at_ = CameraFocus
	var focus_point_position := focus_point.global_position
	if not focus_point_position.is_equal_approx(camera_focus_position):
		var new_focus = lerp(focus_point_position, camera_focus_position, follow_speed)
		_rotate_offset(new_focus)
		focus_point.global_position = new_focus

func _rotate_offset(new_focus: Vector3) -> void:
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var old_offset_projected := Vector3(-offset.x, 0, -offset.z)
	var center := focus_point.global_position + offset
	var center_projected := Vector3(center.x, 0, center.z)

	var new_direction := new_focus_projected - center_projected
	var alpha := new_direction.angle_to(old_offset_projected)

	var decider = new_direction.cross(old_offset_projected)
	var signed_alpha: float = alpha if decider.y < 0 else -alpha
	offset = offset.rotated(Vector3.UP, signed_alpha)

func _move_camera_mount() -> void:
	var camera_focus_position: Vector3 = root_player.camera_focus.global_position
	camera_mount.global_position = camera_mount.global_position.lerp(camera_focus_position, follow_speed)
	camera_nest.global_position = camera_mount.global_position + offset

func _move_camera(delta: float) -> void:
	# TODO: compare to tutorial
	var camera_nest_position = camera_nest.global_position
	var orig = camera.global_transform.origin.lerp(camera_nest_position, delta * lerp_speed)
	camera.global_transform = Transform3D(camera.global_transform.basis, orig)
	camera.look_at(focus_point.global_position, Vector3.UP)


func input_mouse_movement(d_x: float, d_y: float) -> void:
	offset = offset.rotated(Vector3.UP, -d_x * hor_sense * 0.001)

	var axis := offset.cross(Vector3.UP).normalized()
	var angle = d_y * ver_sense * 0.001
	var new_offset = offset.rotated(axis, angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	if new_offset_angle > min_vertical_angle and new_offset_angle < max_vertical_angle:
		offset = new_offset

func input_target_lock():
	var locked_target = _find_target()
	if locked_target:
		fancy_camera.is_target_locked = true
		print("fancy_camera.is_target_locked = true ", fancy_camera.is_target_locked)
		fancy_camera.current_state = locked_camera
		fancy_camera.locked_target = locked_target
		locked_camera.look_at_ = locked_target.look_at_point
		locked_camera.offset = camera_nest.global_position - camera_mount.global_position

func _find_target() -> Node3D:
	var possible_targets = get_tree().get_nodes_in_group("targetable")
	for possible_target in possible_targets:
		if not camera.is_position_in_frustum(possible_target.global_position):
			possible_targets.erase(possible_target)
		if fancy_camera.root_player.camera_focus.global_position.distance_squared_to(possible_target.global_position) > TARGET_DROP_DISTANCE_SQUARED:
			possible_targets.erase(possible_target)
	if not possible_targets.is_empty():
		return possible_targets[0]
	return null

func input_switch_mouse():
	if fancy_camera.mouse_is_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	fancy_camera.mouse_is_captured = not fancy_camera.mouse_is_captured

# region: ORIGINAL
# func update():
#     move_focus_point()
#     move_camera_mount()
#     move_camera()

# func move_focus_point():
#     if not focus_point.global_position.is_equal_approx(look_at_.global_position):
#         var new_focus = lerp(focus_point.global_position, look_at_.global_position, 0.05)
#         rotate_offset(new_focus)
#         focus_point.global_position = new_focus

# func move_camera_mount():
#     camera_mount.global_position = lerp(
#         camera_mount.global_position,
#         fancy_camera.root_player.camera_focus.global_position,
#         0.05
#     )
#     camera_nest.global_position = camera_mount.global_position + offset

# func move_camera():
#     if not camera.position.is_equal_approx(camera_nest.position):
#         camera.position = camera_nest.position
#     camera.look_at_(focus_point.global_position)

# func rotate_offset(new_focus : Vector3):
#     var new_focus_projected = new_focus
#     new_focus_projected.y = 0

#     var old_offset_projected = -offset
#     old_offset_projected.y = 0

#     var center = focus_point.global_position + offset
#     var center_projected = center
#     center_projected.y = 0

#     var new_direction = new_focus_projected - center_projected
#     var alpha = new_direction.angle_to(old_offset_projected)

#     var decider = new_direction.cross(old_offset_projected)
#     if decider.y < 0:
#         offset = offset.rotated(Vector3.UP, alpha)
#     else:
#         offset = offset.rotated(Vector3.UP, -alpha)
# endregion
