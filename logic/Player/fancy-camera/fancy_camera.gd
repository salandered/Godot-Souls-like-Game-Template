extends Node
class_name FancyCamera

@export_group("Following Weights")
@export var FREE_MOUNT_CHEST_WEIGHT: float = 0.1 # tested with 0.1
@export var FREE_FOCUS_CHEST_WEIGHT: float = 0.1 # tested with 0.1
@export var FREE_NEST_MOUNT_WEIGHT: float = 0.7 # tested with 0.9

@export var LOCKED_FOCUS_TARGET_WEIGHT: float = 0.05 # Base 0.05. Range: 0.03 to 0.08
@export var LOCKED_MOUNT_CHEST_WEIGHT: float = 0.12
# NOTE: important to keep them equal for now
#       If different, big camera snap on unlocking.  
#       If both small, free cam super unresponsive 
@export var LOCKED_NEST_MOUNT_WEIGHT: float = FREE_NEST_MOUNT_WEIGHT

@export_group("Blend change state Settings")
@export var OFFSET_BLEND_DURATION_ON_LOCK: float = 0.6
@export var OFFSET_BLEND_DURATION_ON_UNLOCK: float = 0.6
@export var FREEZE_FRAMES_ON_UNLOCK := 1

@export_group("Collision Settings")
@export var COL_EXPAND_TIME: float = 0.35 # how fast to float back to default
@export var COL_MAX_EXPAND_SPEED: float = 12.0
@export var COL_OFFSET: float = 0.2
@export var COLLISION_CAM_RADIUS: float = 0.15 # try 0.25–0.35

@export_group("CAM_MOVEMENT")
@export var HOR_SENSE: float = 1 # 2.5 – 6.0 (0.14°–0.34°/px). Lower if you have a huge mousepad / high DPI.
@export var VER_SENSE: float = HOR_SENSE * 0.8 # 70–90% of horizontal (so 1.8 – 5.0 if you follow the same 0.001 scale).
	# angle = 0° → camera straight above the mount (offset pointing straight up)
	# angle = 90° → camera level with the mount (offset perfectly horizontal)
	# angle = 180° → camera straight below the mount
# => min is kinda max (high cam angle), and max is lower camera guard
# also todo keep them in degs, and rads are in math
@export var MIN_VERTICAL_ANGLE: float = deg_to_rad(22.0) # ≈ 0.384 # 15 – 25
@export var MAX_VERTICAL_ANGLE: float = deg_to_rad(130.0) # ≈ 2.268 # 120 – 135
# Bigger = less flicker on the rail, smaller = crisper limit
@export var VERT_EPS: float = deg_to_rad(0.3) # ≈ 0.0052 | 0.003 is ~0.17° tolerance # 0.2 – 0.6

@export_group("Other")
@export var LOCKED_MAX_YAW_SPEED_DEG_PER_SEC: float = 360.0 # Locking Smoothing
@export var TARGET_DROP_DISTANCE_SQUARED: float = 400.0
@export var look_at_: Node3D # CameraFocus or target

## DOCS
# - Camera looks constantly at Focus Point and tries to position itself on Camera Nest
# - Focus Point follows target, either the player or the enemy.
# - Offset - Vector from the pivot (mount/chest) to the cam. Defines the camera's arm length.
# - Camera Focus - player's chest that is followed by a Focus Point while in free state. NOTE: Child of the Player
# - Camera Mount - for now it follows player's chest and equal to FocusPoint in a free state.
# - Camera Nest - where camera should be (pre-collision). Nest = Mount + offset
# - Focus Point, Mount, Nest and PlayerCamera are children of Fancy Camera.
#
# - So it all follows each other:
#	Focus Point -> LookAt (CameraFocus or target)
#	Camera Mount -> Player
#	Camera Nest -> Camera Mount + offset
#	Camera -> Camera Nest
@onready var player: Princess = $".."
@onready var focus: Node3D = %FocusPoint
@onready var mount: Node3D = %CameraMount
@onready var nest: Node3D = %CameraNest
@onready var camera: Camera3D = %PlayerCamera

@onready var current_state: CameraState = $FreeCamera
@onready var free_state: FreeCameraState = %FreeCamera
@onready var locked_state: LockedCameraState = %LockedCamera

@onready var camera_movement: CameraMovement = %CameraMovement


var SPRING_ARM_COLLISION_MASK := 1 # to do: collision sys

var locked_target: Node3D

var accumulated_mouse_delta := Vector2.ZERO

var FREE_STATE_NAME := "free_state"
var LOCKED_STATE_NAME := "locked_state"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	__csg_objects = get_descendants.csg(self)

	__toggle_camera_visuals()
	
	initialise()


func initialise() -> void:
	# POSITIONS INIT
	# 1. look_at_ is always Player's chest (CameraFocus) in the Free State
	# 2. Free State is always first state to enter 
	# => we treat look_at_ as chest here in initialise() 
	var chest := look_at_

	focus.global_position = chest.global_position # Focus Point to player's chest
	mount.global_position = chest.global_position # same
	
	# Calculate initial_offset based on player's forward direction
	# was: initial_offset = fc.nest.global_position - fc.mount.global_position
	# HERE IS INITIAL LENGTH BETWEEN PLAYER AND CAMERA. NOT IN THE VIEWPORT
	var _player_forward := -player.global_transform.basis.z
	var initial_offset := _player_forward * 3.0 + Vector3(0, 2.0, 0) # 5 units behind, 2 units up
	
	nest.global_position = mount.global_position + initial_offset # nest relative to mount using the free_offset
	
	camera.global_position = nest.global_position # may be position closer in case of wall
	
	# FREE STATE INIT
	free_state.fc = self
	free_state.chest = chest
	free_state.free_offset = initial_offset
	free_state.state_name = FREE_STATE_NAME

	# LOCKED STATE INIT
	locked_state.fc = self
	locked_state.state_name = LOCKED_STATE_NAME

	# CAMERA INIT
	camera_movement._default_len = initial_offset.length()
	camera_movement._current_len = initial_offset.length()
	
	print_.fancy_cam("", "Fancy Camera Initialisation ended." + " Initial_offset is " + __free_off())


func _process(delta: float) -> void:
	# TODO: target switch on mouse move (or mouse scroll which is simplier)
	# NOTE: this is second place when we gather input (main being in pl model for pl SM)
	#   And i currently think it's ok for different systems to listen to input. 
	#   Another approach would be gathering it in one place and then sending commands / signals to camera etc.
	var d_x := accumulated_mouse_delta.x
	var d_y := accumulated_mouse_delta.y
	accumulated_mouse_delta = Vector2.ZERO
	
	var input_: InputPackage = InputManager._current_input
	# print(u.fr() + "//~~~CAM ", input.target_lock)

	_consider_switching_state(input_)

	current_state.input_mouse_movement(d_x, d_y)
	current_state.update(delta)


func _consider_switching_state(input_: InputPackage):
	if input_.target_lock.no_tap():
		return

	match current_state.state_name:
		FREE_STATE_NAME when input_.target_lock.tap_or_double_tap():
			var found_target := player.model.area_awareness.find_target()
			if found_target:
				print_.fancy_cam("FREE -> LOCKED ", __Cvec() + __free_off() + " target=" + str(found_target))
				
				locked_target = found_target
				current_state = locked_state
				
				locked_state.switch_from_free(locked_target)
			else:
				print_.fancy_cam("", em.gray_x + "LOCK NOT (no target found)")
		LOCKED_STATE_NAME when input_.target_lock.tap:
			print_.fancy_cam("LOCKED -> FREE", "")
			locked_target = nest
			current_state = free_state
			free_state.switch_from_locked()

func is_locked_state():
	return current_state.state_name == LOCKED_STATE_NAME

func is_free_state():
	return current_state.state_name == FREE_STATE_NAME


## NOTE. This is here and not in auto loaded input_manager.gd
## - Mouse motion is fundamentally different (event-based vs frame-based)
## - Camera is the only thing that needs mouse motion anyway
## If this changes - consider moving to that singleton.
func _input(event):
	if event is InputEventMouseMotion: # todo: get such data in InGatherer as well?
		accumulated_mouse_delta += event.relative

	# dev
	if event.is_action_released("dev_camera_fov"):
		__change_fov()
	
	if event.is_action_pressed("debug_toggle_nest"):
		print_.fancy_cam("", "Toggling visibility of CSG objects for " + str(len(__csg_objects)) + " objects")
		__dev_camera_visuals = not __dev_camera_visuals
		__toggle_camera_visuals()

	if event.is_action_pressed("dev_camera_cols"):
		__dev_camera_cols = not __dev_camera_cols
		print_.fancy_cam("", "dev_camera_cols")


# region: DEV

var __fov_pointer := 0
var __dev_camera_cols := true
var __dev_camera_visuals := false
var __csg_objects := []


func __toggle_camera_visuals():
	for obj in __csg_objects:
		obj.visible = __dev_camera_visuals
	

func __dbg_main_info() -> String:
	var r = __Cvec() + __Mvec() + __Nvec() + __Fvec() + __free_off() + __lock_off()
	return r

func __free_off() -> String:
	var r = " free off=" + pp.vec3(free_state.free_offset) + " len=" + pp.round_01(free_state.free_offset.length())
	return r

func __lock_off() -> String:
	var r = " lock off=" + pp.vec3(locked_state.lock_offset) + " len=" + pp.round_01(locked_state.lock_offset.length())
	return r

func __Cvec() -> String:
	return " C=" + pp.vec3(camera.global_position)

func __Mvec() -> String:
	return " M=" + pp.vec3(mount.global_position)

func __Nvec() -> String:
	return " N=" + pp.vec3(nest.global_position)

func __Fvec() -> String:
	return " F=" + pp.vec3(focus.global_position)

func __CP() -> String:
	return " C->Pl=" + pp.round_01((camera.global_position - player.camera_focus.global_position).length())

func __CN() -> String:
	return " C->N=" + pp.round_01((camera.global_position - nest.global_position).length())

func __CM() -> String:
	return " C->M=" + pp.round_01((camera.global_position - mount.global_position).length())

func __CF() -> String:
	return " C->F=" + pp.round_01((camera.global_position - focus.global_position).length())

func __angle_player_camera_target() -> String:
	# Vectors from player and camera to the target, projected to XZ
	var player_to_target := Vector2(locked_target.global_position.x - player.camera_focus.global_position.x, locked_target.global_position.z - player.camera_focus.global_position.z).normalized()
	var camera_to_target := Vector2(locked_target.global_position.x - camera.global_position.x, locked_target.global_position.z - camera.global_position.z).normalized()

	var angle := str(rad_to_deg(player_to_target.angle_to(camera_to_target)))
	return angle

func __change_fov():
	print_.dev("", "changed fov")
	__fov_pointer += 1
	var fovs = [10, 25, 50, 100]
	var fov = fovs[__fov_pointer % fovs.size()]
	camera.fov = fov

# endregion

# TODO: Heard that real game dev terms are:
# Boom: vector from pivot (mount/chest) to the camera. Now is free_offset / lock_offset.
# Boom length: _default_len and _current_len.
# Pivot: the anchor to orbit around (mount).
# Desired/ideal camera: nest (pre-collision point).
# Resolved/actual camera: camera after collision solver.
