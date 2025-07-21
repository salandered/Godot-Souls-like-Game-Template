extends CameraState
class_name LockedCameraState


@onready var root_player: CharacterBody3D = $"../.."
@onready var fancy_camera: FancyCamera = $".."
@onready var focus_point: Node3D = %FocusPoint
@onready var camera_nest: Node3D = %CameraNest
@onready var camera_mount: Node3D = %CameraMount
@onready var camera: Camera3D = %PlayerCamera
@onready var free_camera: FreeCameraState = %FreeCamera

var look_at_: Node3D
var offset: Vector3

@export var hor_sense: float = 1.0
@export var ver_sense: float = 1.0

@export var min_vertical_angle: float = 0.62
@export var max_vertical_angle: float = 1.87

@export var follow_speed: float = 0.05
@export var lerp_speed: float = 8.0


const FOCUS_FOLLOWING_WEIGHT = 0.1
const CAM_MOUNT_FOLLOWING_WEIGHT = 0.12
const CAM_NEST_FOLLOWING_WEIGHT = 0.07
const TARGET_DROP_DISTANCE_SQUARED = 64

func _ready():
	look_at_ = fancy_camera.look_at_
	print("LockedCameraState ready()")
	print("		root_player ", root_player)
	print("		look_at_ ", look_at_)


func update(delta: float) -> void:
	_move_focus_point()
	_move_camera_nest()
	_move_camera()
	_check_distance()

func _move_focus_point() -> void:
	var new_focus = lerp(focus_point.global_position, look_at_.global_position, FOCUS_FOLLOWING_WEIGHT)
	_rotate_offset_locked(new_focus)
	focus_point.global_position = new_focus

func _move_camera_nest() -> void:
	camera_mount.global_position = lerp(
		camera_mount.global_position,
		root_player.camera_focus.global_position,
		CAM_MOUNT_FOLLOWING_WEIGHT
	)
	camera_nest.global_position = lerp(
		camera_nest.global_position,
		camera_mount.global_position + offset,
		CAM_NEST_FOLLOWING_WEIGHT
	)

func _move_camera() -> void:
	if not camera.position.is_equal_approx(camera_nest.position):
		camera.position = camera_nest.position
	camera.look_at(focus_point.global_position, Vector3.UP) # no Vector3.UP in tut

func _rotate_offset_locked(new_focus: Vector3) -> void:
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var center_projected : Vector3= root_player.camera_focus.global_position
	center_projected.y = 0
	var offset_xz_length := sqrt(offset.x * offset.x + offset.z * offset.z)
	var new_offset := (center_projected - new_focus_projected).normalized() * offset_xz_length
	new_offset.y = offset.y
	offset = new_offset

func _check_distance() -> void:
	var distance = root_player.global_position.distance_squared_to(fancy_camera.locked_target.global_position)
	if distance > TARGET_DROP_DISTANCE_SQUARED:
		_drop_target()

func input_target_lock():
	_drop_target()

func _drop_target() -> void:
	free_camera.look_at_ = root_player.camera_focus
	free_camera.offset = camera_nest.global_position - camera_mount.global_position
	fancy_camera.current_state = free_camera
	fancy_camera.is_target_locked = false
	fancy_camera.locked_target = camera_nest

func input_mouse_movement(d_x: float, d_y: float) -> void:
	# nothing to do in locked state
	pass

func input_switch_mouse() -> void:
	if fancy_camera.mouse_is_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	fancy_camera.mouse_is_captured = not fancy_camera.mouse_is_captured
