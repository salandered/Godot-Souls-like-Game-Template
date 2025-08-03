extends Node
class_name FancyCamera


@export_group("Locked camera")
@export var FOCUS_FOLLOWING_WEIGHT = 0.1
@export var CAM_MOUNT_FOLLOWING_WEIGHT = 0.12
@export var CAM_NEST_FOLLOWING_WEIGHT = 0.07
@export var OFFSET_BLEND_DURATION_ON_LOCK := 0.6
@export var TARGET_DROP_DISTANCE_SQUARED = 200


@export_group("Free camera")
@export var HOR_SENSE: float = 1.0
@export var VER_SENSE: float = 1.0
@export var MIN_VERTICAL_ANGLE: float = 0.62
@export var MAX_VERTICAL_ANGLE: float = 1.87
@export var FOLLOW_SPEED: float = 0.05


@onready var csg_sphere_nest: CSGSphere3D = %CSGSphereNest
@export var look_at_: Node3D # assign Player/CameraFocus here

# DOCS
# - Camera looks constantly at Focus Point and tries to position itself on Camera Nest, located relatively to the Focus Point.
# - Focus Point follows target, either the player or the enemy.
# - Offset Vector is important, it defines the camera's arm length.
# - Camera Focus is the player's chest zone that is being followed by a Focus Point.
# - Focus Poing, Mount, Nest and PlayerCamera are children of Fancy Camera.
@onready var player: CharacterBody3D = $".."
@onready var root_player: CharacterBody3D = $".."
@onready var focus: Node3D = $FocusPoint
@onready var mount: Node3D = $CameraMount
@onready var nest: Node3D = $CameraNest
@onready var camera: Camera3D = $PlayerCamera

@onready var current_state: CameraState = $FreeCamera
@onready var free_camera: FreeCameraState = %FreeCamera
@onready var locked_camera: LockedCameraState = %LockedCamera

var fov_pointer := 0

var SPRING_ARM_COLLISION_MASK = 1
@export var PLAYER_ROTATE_SPEED: float = 5.0

var mouse_is_captured: bool = true
var locked_target: Node3D

func _ready() -> void:
	# TODO: length is changing after locking
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	free_camera.initialise()
	print('FancyCamera ready ')
	print("		player ", player)

func _physics_process(delta: float) -> void:
	current_state.update(delta)


func _input(event):
	# TODO: target switch on mouse move (or mouse scroll which is simplier)
	if event.is_action_released("lock_target"):
		print("PRESSED lock_target")
		current_state.input_target_lock()

	if event.is_action_released("mouse_mode_switch"):
		input_switch_mouse()

	if event is InputEventMouseMotion and mouse_is_captured:
		var d_hor = event.relative.x
		var d_ver = event.relative.y
		current_state.input_mouse_movement(d_hor, d_ver)

	if event.is_action_pressed("debug_toggle_nest"):
		csg_sphere_nest.visible = !csg_sphere_nest.visible

func input_switch_mouse():
	if mouse_is_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_is_captured = not mouse_is_captured


func _unhandled_input(event):
	if event.is_action_released("dev_camera_fov"):
		change_fov()

func change_fov():
	fov_pointer += 1
	var fovs = [10, 25, 50, 100]

	var fov = fovs[fov_pointer % fovs.size()]

	camera.fov = fov
