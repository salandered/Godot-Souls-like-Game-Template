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
@export var MIN_VERTICAL_ANGLE: float = 0.12
@export var MAX_VERTICAL_ANGLE: float = 2.2
@export var FOLLOW_SPEED: float = 0.05


#@onready var csg_sphere_nest: CSGSphere3D = %CSGSphereNest
@export var look_at_: Node3D # CameraFocus node here!

# DOCS
# - Camera looks constantly at Focus Point and tries to position itself on Camera Nest, located relatively to the Focus Point.
# - Focus Point follows target, either the player or the enemy.
# - Offset Vector is important, it defines the camera's arm length.
# - Camera Focus is the player's chest zone that is being followed by a Focus Point.
# - Focus Poing, Mount, Nest and PlayerCamera are children of Fancy Camera.
@onready var player: Princess = $".."
@onready var focus: Node3D = %FocusPoint
@onready var mount: Node3D = %CameraMount
@onready var nest: Node3D = %CameraNest
@onready var camera: Camera3D = %PlayerCamera

@onready var current_state: CameraState = $FreeCamera
@onready var free_camera: FreeCameraState = %FreeCamera
@onready var locked_camera: LockedCameraState = %LockedCamera

var fov_pointer := 0

var SPRING_ARM_COLLISION_MASK = 1
@export var PLAYER_ROTATE_SPEED: float = 5.0


var locked_target: Node3D

var __dev_camera_cols := false

var csg_objects = []


func _get_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is CSGBox3D or child is CSGSphere3D:
			descendants.append(child)
		descendants.append_array(_get_descendants(child))
	return descendants

func _ready() -> void:
	# TODO: length is changing after locking
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	free_camera.initialise()
	print('FancyCamera ready ')
	
	
	csg_objects = _get_descendants(self)


func _process(delta: float) -> void:
	var input: InputPackage = player.model.area_awareness.last_input_package
	# TODO: target switch on mouse move (or mouse scroll which is simplier)
	
	
	if input.target_lock_pressed:
		current_state.input_target_lock()

	current_state.update(delta)


func _input(event):
	if event is InputEventMouseMotion:
		var d_hor = event.relative.x
		var d_ver = event.relative.y
		current_state.input_mouse_movement(d_hor, d_ver)

	
	if event.is_action_released("dev_camera_fov"):
		_change_fov()
	
	if event.is_action_pressed("debug_toggle_nest"):
		print("Toggling visibility of CSG objects for ", len(csg_objects), " objects")
		for obj in csg_objects:
			obj.visible = not obj.visible

	if event.is_action_pressed("dev_camera_cols"):
		__dev_camera_cols = not __dev_camera_cols
		print("dev_camera_cols")


func _change_fov():
	print("changed fov")
	fov_pointer += 1
	var fovs = [10, 25, 50, 100]

	var fov = fovs[fov_pointer % fovs.size()]

	camera.fov = fov
