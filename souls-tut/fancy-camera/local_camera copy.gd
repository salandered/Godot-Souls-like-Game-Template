extends Node
# class_name FancyCamera

@export var look_at: Node3D # assign Player/CameraFocus here
var root_player: LocalPlayer

@export var hor_sense: float = 1.0
@export var ver_sense: float = 1.0
@export var min_vertical_angle: float = 0.1
@export var max_vertical_angle: float = 2.0
@export var follow_speed: float = 0.05
@export var lerp_speed: float = 8.0

@onready var focus_point: Node3D = $FocusPoint
@onready var camera_mount: Node3D = $CameraMount
@onready var camera_nest: Node3D = $CameraNest
@onready var camera: Camera3D = $PlayerCamera


var is_target_locked := false

var offset: Vector3

func _ready() -> void:
    offset = camera_nest.position
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# func _process(delta: float) -> void:
