extends BaseNodeSystem
class_name FancyCamera

@export_group("Following Weights")
@export var FREE_MOUNT_CHEST_WEIGHT: float = 0.1 # tested with 0.1
@export var FREE_FOCUS_CHEST_WEIGHT: float = 0.1 # tested with 0.1
@export var FREE_NEST_MOUNT_WEIGHT: float = 0.7 # tested with 0.9

@export var LOCKED_FOCUS_TARGET_WEIGHT: float = 0.05 # Base 0.05. Range: 0.03 to 0.08
@export var LOCKED_MOUNT_CHEST_WEIGHT: float = 0.12
# WARNING: important to keep them equal for now
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
## by default 0.8 of HOR_SENSE
@export var VER_SENSE: float = HOR_SENSE * 0.8 # 70–90% of horizontal
## Used only when locked to target
@export var LOCKED_VER_SENSE: float = 0.7
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

@onready var free_state: FreeCameraState = %FreeCamera
@onready var locked_state: LockedCameraState = %LockedCamera

@onready var camera_movement: CameraMovement = %CameraMovement

## not nullable
var current_state: CameraState


var SPRING_ARM_COLLISION_MASK := 1 # to do: use Collision


## not nullable
var locked_target: BaseCameraTarget

var accumulated_mouse_delta := Vector2.ZERO

var FREE_STATE_NAME := "free_state"
var LOCKED_STATE_NAME := "locked_state"


func get_hard_dependencies() -> Array[Object]:
	return [
		player,
		focus,
		mount,
		nest,
		camera,
		free_state,
		locked_state,
		camera_movement,
		locked_target,
		current_state,
	]


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	# TODO WARNING: HERE IS INITIAL LENGTH BETWEEN PLAYER AND CAMERA. NOT IN THE VIEWPORT
	# 		make some configurable system!
	var _player_forward := -player.global_transform.basis.z
	var initial_offset := _player_forward * 2.0 + Vector3(0, 1.0, 0) # 5 units behind, 2 units up
	
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
	current_state = free_state
	locked_target = nest
	camera_movement._default_len = initial_offset.length()
	camera_movement._current_len = initial_offset.length()

	
	__dev_initialise()
	
	__log_("", "Initialisation ended.", "Initial_offset is", __free_off())
	if not __validate_deps_set_init():
		__log_error(pp.s("Failed to init"), "", "doesn't matter, without camera nothing can't be done")


func is_locked_state():
	return current_state.state_name == LOCKED_STATE_NAME


func is_camera_locked_to_target() -> bool:
	return is_locked_state()


func is_free_state():
	return current_state.state_name == FREE_STATE_NAME


func _process(delta: float) -> void:
	if __could_not_initialised():
		return
	# TODO: target switch on mouse move (or mouse scroll which is simplier)
	# NOTE: this is second place when we gather input (main being in pl model for pl SM)
	#   And i currently think it's ok for different systems to listen to input. 
	#   Another approach would be gathering it in one place and then sending commands / signals to camera etc.
	var d_x := accumulated_mouse_delta.x
	var d_y := accumulated_mouse_delta.y
	accumulated_mouse_delta = Vector2.ZERO
	
	var input_: InputPackage = InputManager._current_input

	# NOTE: seems like better to do movement before switching_state
	# because locked -> free could use last mouse movement from locked
	current_state.input_mouse_movement(d_x, d_y)

	_consider_switching_state(input_)

	current_state.update(delta)


func _consider_switching_state(input_: InputPackage):
	match current_state.state_name:
		FREE_STATE_NAME:
			if input_.target_lock.no_tap():
				return
			if input_.target_lock.tap_or_double_tap():
				var found_target := player.area_awareness.find_target()
				if found_target:
					_switch_locked_from_free(found_target)
				else:
					__log_("", em.gray_x, "LOCK NOT (no target found)")
		LOCKED_STATE_NAME:
			if not locked_target.is_active():
				_switch_free_from_locked("target not active!")
			if input_.target_lock.no_tap():
				return
			if input_.target_lock.tap:
				_switch_free_from_locked("input_.target_lock.tap")
		_:
			__log_error("unknown current state!", "", "", current_state.state_name)


func _switch_free_from_locked(reason: String = ""):
	__log_("LOCKED -> FREE", "reason", reason)
	locked_target = nest
	current_state = free_state
	free_state.switch_from_locked()


func _switch_locked_from_free(found_target: EnemyCameraTarget):
	__log_("FREE -> LOCKED", __Cvec(), __free_off(), "target=", found_target.pp_name())
				
	locked_target = found_target
	current_state = locked_state
	
	locked_state.switch_from_free(locked_target)


## NOTE. This is here and not in auto loaded input_manager.gd
## - Mouse motion is fundamentally different (event-based vs frame-based)
## - Camera is the only thing that needs mouse motion anyway
## If this changes - consider moving to that singleton.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		accumulated_mouse_delta += event.relative

	_dev_input(event)


## __LOGS
# region

func pp_name() -> String:
	return "🎥 Cam"

func __LOG_B() -> bool:
	return LogToggler.FANCY_CAM_B

func __LOG_INDENT() -> int:
	return 0

# endregion


# region: DEV

var __fov_pointer := 0
var __dev_camera_cols := true
var __dev_camera_visuals := false
var __csg_objects := []

var fov_cycler: Cycler


func __dev_initialise() -> void:
	if not OS.is_debug_build():
		return
	__csg_objects = get_descendants.csg_primitives(self)
	__toggle_camera_visuals()

	fov_cycler = Cycler.new([50, 60, 70, 80])


func __change_fov():
	var fov = fov_cycler.get_next()
	print_.dev("", pp.s("changed fov to", fov))
	camera.fov = fov


func __toggle_camera_visuals():
	for obj in __csg_objects:
		obj.visible = __dev_camera_visuals
	

func _dev_input(event: InputEvent):
	if not OS.is_debug_build():
		return

	if event.is_action_released(RawAction.DEV_CAM_fov):
		__change_fov()
	
	if event.is_action_pressed(RawAction.DEV_toggle_nest):
		__log_("", "Toggling visibility of CSG objects for", len(__csg_objects), "objects")
		__dev_camera_visuals = not __dev_camera_visuals
		__toggle_camera_visuals()

	if event.is_action_pressed(RawAction.DEV_CAM_cols):
		__dev_camera_cols = not __dev_camera_cols
		__log_("", "dev_camera_cols")


# region: dev LOGS

func __dbg_main_info() -> String:
	var r = pp.s(__Cvec(), __Mvec(), __Nvec(), __Fvec(), __free_off(), __lock_off())
	return r

func __free_off() -> String:
	var r = pp.s("free off=", free_state.free_offset, "len=", free_state.free_offset.length())
	return r

func __lock_off() -> String:
	var r = pp.s("lock off=", locked_state.lock_offset, "len=", locked_state.lock_offset.length())
	return r

func __Cvec() -> String:
	return pp.s("C=", pp.vec3(camera.global_position))

func __Mvec() -> String:
	return pp.s("M=", pp.vec3(mount.global_position))

func __Nvec() -> String:
	return pp.s("N=", pp.vec3(nest.global_position))

func __Fvec() -> String:
	return pp.s("F=", pp.vec3(focus.global_position))

func __CP() -> String:
	return pp.s("C->Pl=", (camera.global_position - player.camera_focus.global_position).length())

func __CN() -> String:
	return pp.s("C->N=", (camera.global_position - nest.global_position).length())

func __CM() -> String:
	return pp.s("C->M=", (camera.global_position - mount.global_position).length())

func __CF() -> String:
	return pp.s("C->F=", (camera.global_position - focus.global_position).length())

func __angle_player_camera_target() -> String:
	# Vectors from player and camera to the target, projected to XZ
	var player_to_target := Vector2(
		locked_target.global_position.x - player.camera_focus.global_position.x,
		locked_target.global_position.z - player.camera_focus.global_position.z).normalized()
	var camera_to_target := Vector2(
		locked_target.global_position.x - camera.global_position.x,
		locked_target.global_position.z - camera.global_position.z).normalized()

	var angle := str(rad_to_deg(player_to_target.angle_to(camera_to_target)))
	return angle

# endregion

# endregion

# TODO: Probably real game dev terms:
# Boom: vector from pivot (mount/chest) to the camera. Now is free_offset / lock_offset.
# Boom length: _default_len and _current_len.
# Pivot: the anchor to orbit around (mount).
# Desired/ideal camera: nest (pre-collision point).
# Resolved/actual camera: camera after collision solver.
