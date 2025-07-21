extends Node
class_name FancyCamera

@export var look_at_: Node3D # assign Player/CameraFocus here


@export var hor_sense: float = 1.0
@export var ver_sense: float = 1.0
@export var min_vertical_angle: float = 0.1
@export var max_vertical_angle: float = 2.0
@export var follow_speed: float = 0.05
@export var lerp_speed: float = 8.0

@onready var root_player: CharacterBody3D = $".."
@onready var focus_point: Node3D = $FocusPoint
@onready var camera_mount: Node3D = $CameraMount
@onready var camera_nest: Node3D = $CameraNest
@onready var camera: Camera3D = $PlayerCamera

var mouse_is_captured: bool = true

@onready var current_state: CameraState = $FreeCamera
@onready var free_camera: FreeCameraState = %FreeCamera
@onready var locked_camera: LockedCameraState = %LockedCamera

var is_target_locked := false
var locked_target: Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print('FancyCamera ready ')
	print("		root_player ", root_player)

func _physics_process(delta: float) -> void:
	current_state.update(delta)


func _input(event):
	if event.is_action_released("lock_target"):
		current_state.input_target_lock()

	if event.is_action_released("mouse_mode_switch"):
		current_state.input_switch_mouse()

	if event is InputEventMouseMotion and mouse_is_captured and not is_target_locked:
		var d_hor = event.relative.x
		var d_ver = event.relative.y
		current_state.input_mouse_movement(d_hor, d_ver)
