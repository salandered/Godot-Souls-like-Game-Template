extends NodeSystem
class_name FancyCamera

@export_group("Following Weights")
@export var FREE_SOCKET_CHEST_WEIGHT: float = 0.1 # tested with 0.1
@export var FREE_AIM_CHEST_WEIGHT: float = 0.09 # tested with 0.1
@export var FREE_SOCKET_PIVOT_WEIGHT: float = 0.7 # tested with 0.9

@export var LOCKED_AIM_TARGET_WEIGHT: float = 0.05 # Base 0.05. Range: 0.03 to 0.08
@export var LOCKED_PIVOT_CHEST_WEIGHT: float = 0.11
# WARNING: important to keep them equal for now
#       If different, big camera snap on unlocking.  
#       If both small, free cam super unresponsive 
var LOCKED_SOCKET_PIVOT_WEIGHT: float = FREE_SOCKET_PIVOT_WEIGHT

@export_group("Blend change state Settings")
@export var BOOM_BLEND_DURATION_ON_LOCK: float = 0.6
@export var BOOM_BLEND_DURATION_ON_UNLOCK: float = 0.6
@export var FREEZE_FRAMES_ON_UNLOCK := 1

@export_group("Collision Settings")
@export var COL_EXPAND_TIME: float = 0.35 # how fast to float back to default
@export var COL_MAX_EXPAND_SPEED: float = 12.0
@export var COL_OFFSET: float = 0.2
@export var COLLISION_CAM_RADIUS: float = 0.15 # try 0.25–0.35

@export_group("CAM_MOVEMENT")
@export var DEF_X_SENSE: float = 1 # 2.5 – 6.0 (0.14°–0.34°/px). Lower if you have a huge mousepad / high DPI.
## by default 0.8 of DEF_X_SENSE
@export var DEF_Y_SENSE: float = 0.8 # 70–90% of horizontal
## Used only when locked to target
## applies to y sense
@export var DEF_LOCKED_Y_SENSE_MULT: float = 0.9
	# angle = 0° → camera straight above the pivot (boom pointing straight up)
	# angle = 90° → camera level with the pivot (boom perfectly horizontal)
	# angle = 180° → camera straight below the pivot
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
## Terminology
# - [Pivot]: The anchor point attached to the Player's chest.
# - [Boom]: The rigid vector from Pivot to Socket (ideal arm length/direction).
# - [Socket]: The ideal position at the end of the Boom (pre-collision) for a cam.
# - [Aim]: The point in space the Camera faces (rotates.
## DESC
# - Camera looks constantly at Aim and tries to position itself on Camera Socket
# - Aim follows target, either the player or the enemy.
# - Boom - Vector from the pivot (pivot/chest) to the cam. Defines the camera's arm length.
# - Camera Focus - player's chest that is followed by an Aim while in free state. NOTE: Child of the Player
# - Camera Pivot - for now it follows player's chest and is positioned similar to Aim in a free state.
# - Camera Socket - where camera should be (pre-collision). Socket = Pivot + Boom
# - Aim, Pivot, Socket and PlayerCamera are children of Fancy Camera.
## 
# - So it all follows each other:
#	Aim -> LookAt (CameraFocus or target)
#	Camera Pivot -> Player
#	Camera Socket -> Pivot + Boom
#	Camera -> Camera Socket
@onready var player: Princess = $".."
@onready var aim: Node3D = %Aim
@onready var pivot: Node3D = %CameraPivot
@onready var socket: Node3D = %CameraSocket
@onready var camera: Camera3D = %PlayerCamera

@onready var free_state: FreeCameraState = %FreeCamera
@onready var locked_state: LockedCameraState = %LockedCamera

@onready var camera_movement: CameraMovement = %CameraMovement
@onready var circle_target: TargetMarker = %CircleTarget


var mouse_sense: MouseSense

## not nullable
var current_state: CameraState


var SPRING_ARM_COLLISION_MASK := 1 # to do: use Collision


## not nullable
var locked_target: BaseCameraTarget

var accumulated_mouse_delta := Vector2.ZERO

var FREE_STATE_NAME := "free_state"
var LOCKED_STATE_NAME := "locked_state"


var __fov_pointer := 0
var __dev_camera_coll := true
var __fov_cycler: Cycler


func __hard_dependencies() -> Array:
	return [
		player,
		aim,
		pivot,
		socket,
		camera,
		free_state,
		locked_state,
		camera_movement,
		locked_target,
		current_state,
		mouse_sense
	]


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	initialise()


func initialise() -> void:
	# SENSE
	calculate_mouse_sense()


	# POSITIONS INIT
	# 1. look_at_ is always Player's chest (CameraFocus) in the Free State
	# 2. Free State is always first state to enter 
	# => we treat look_at_ as chest here in initialise() 
	var chest := look_at_

	aim.global_position = chest.global_position # Aim to player's chest
	pivot.global_position = chest.global_position # same
	
	# Calculate initial_boom based on player's forward direction
	# was: initial_boom = fc.socket.global_position - fc.pivot.global_position
	# TODO WARNING: HERE IS INITIAL LENGTH BETWEEN PLAYER AND CAMERA. NOT IN THE VIEWPORT
	# 		make some configurable system!
	var _player_forward := -player.global_transform.basis.z
	var initial_boom := _player_forward * 1.6 + Vector3(0, 1.0, 0) # 5 units behind, 2 units up
	
	socket.global_position = pivot.global_position + initial_boom # socket relative to pivot using the free_boom
	
	camera.global_position = socket.global_position # may be position closer in case of wall
	camera.current = true
	set_h_offset_camera(0.0)
	
	# FREE STATE INIT
	free_state.fc = self
	free_state.chest = chest
	free_state.free_boom = initial_boom
	free_state.state_name = FREE_STATE_NAME

	# LOCKED STATE INIT
	locked_state.fc = self
	locked_state.state_name = LOCKED_STATE_NAME

	# CAMERA INIT
	current_state = free_state
	locked_target = socket
	camera_movement._default_len = initial_boom.length()
	camera_movement._current_len = initial_boom.length()

	#
	_toggle_cam_visuals(false)

	## SIGNALS
	SigUtils.safe_connect_pairs(
		[
			[GlobalSignal.SIG_update_mouse_settings_for_camera, _on_update_sense_settings],
			[GlobalSignal.SIG_toggle_camera_visuals, _on_SIG_toggle_camera_visuals],
			[GlobalSignal.SIG_toggle_camera_coll, _on_SIG_toggle_camera_coll]
		]
	)

	__fov_cycler = Cycler.new([50, 60, 70, 80])
	
	__log_("", "Initialisation ended.", "Initial_boom is", __free_boom())
	if not __perform_validation(true):
		__log_error(pp.s("Failed to init"), "", "doesn't matter, without camera nothing can be done")


func calculate_mouse_sense():
	if not mouse_sense:
		mouse_sense = MouseSense.new()
	var x_sense_settings := M_AppSettings.get_x_sense()
	var y_sense_settings := M_AppSettings.get_y_sense()
	# prints("calculate_mouse_sense", x_sense_settings, y_sense_settings)
	mouse_sense.calculate(DEF_X_SENSE, DEF_Y_SENSE, DEF_LOCKED_Y_SENSE_MULT, x_sense_settings, y_sense_settings)


func is_locked_state() -> bool:
	return current_state.state_name == LOCKED_STATE_NAME


func is_camera_locked_to_target() -> bool:
	return is_locked_state()


func is_free_state() -> bool:
	return current_state.state_name == FREE_STATE_NAME


func set_h_offset_camera(h_offset: float) -> void:
	camera.h_offset = h_offset


func _process(delta: float) -> void:
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
				var found_target := player.get_area_awareness().find_target()
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
	locked_target = socket
	current_state = free_state

	circle_target.reset_target()
	

	free_state.switch_from_locked()


func _switch_locked_from_free(found_target: EnemyCameraTarget):
	__log_("FREE -> LOCKED", __Cvec(), __free_boom(), "target=", found_target.pp_name())
				
	locked_target = found_target
	current_state = locked_state

	circle_target.set_target(locked_target)

	
	locked_state.switch_from_free(locked_target)


## NOTE. This is here and not in auto loaded input_manager.gd
## - Mouse motion is fundamentally different (event-based vs frame-based)
## - Camera is the only thing that needs mouse motion anyway
## If this changes - consider moving to that singleton.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		accumulated_mouse_delta += event.relative

	_dev_input(event)


func _on_update_sense_settings() -> void:
	# recalculating
	calculate_mouse_sense()


func _on_SIG_toggle_camera_coll(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, SPS.toggle_field)
	if _r.err: return
	_toggle_cam_coll(_r.value)


func _on_SIG_toggle_camera_visuals(payload: Dictionary[String, Variant]):
	var _r := SigUtils.safe_get_bool_payload_value(payload, SPS.toggle_field)
	if _r.err: return
	var toggle := _r.value
	_toggle_cam_visuals(toggle)
	set_h_offset_camera(+1.0 if toggle else 0.0)


func _toggle_cam_coll(toggle: bool):
	print_.dev("~~", pp.s("_toggle_cam_coll", toggle))
	__dev_camera_coll = toggle


func _toggle_cam_visuals(toggle: bool):
	print_.dev("~~", pp.s("_toggle_cam_visuals", toggle))
	if socket:
		socket.visible = toggle
	if pivot:
		pivot.visible = toggle
	if camera:
		camera.visible = toggle
	if aim:
		aim.visible = toggle

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


func __change_fov():
	var fov = __fov_cycler.get_next()
	print_.dev("", pp.s("changed fov to", fov))
	camera.fov = fov


func _dev_input(event: InputEvent):
	if not OS.is_debug_build():
		return

	if event.is_action_released(RawAction.DEV_CAM_fov):
		__change_fov()


	if event.is_action_pressed(RawAction.DEV_CAM_cols):
		_toggle_cam_coll(not __dev_camera_coll)


# region: dev LOGS

func __dbg_main_info() -> String:
	var r := pp.s(__Cvec(), __Pvec(), __Svec(), __Fvec(), __free_boom(), __lock_boom())
	return r

func __free_boom() -> String:
	var r := pp.s("free off=", free_state.free_boom, "len=", free_state.free_boom.length())
	return r

func __lock_boom() -> String:
	var r := pp.s("lock off=", locked_state.lock_boom, "len=", locked_state.lock_boom.length())
	return r

func __Cvec() -> String:
	return pp.s("C=", pp.vec3(camera.global_position))

func __Pvec() -> String:
	return pp.s("P=", pp.vec3(pivot.global_position))

func __Svec() -> String:
	return pp.s("S=", pp.vec3(socket.global_position))

func __Fvec() -> String:
	return pp.s("F=", pp.vec3(aim.global_position))

func __CPl() -> String:
	return pp.s("C->Pl=", (camera.global_position - player.camera_focus.global_position).length())

func __CS() -> String:
	return pp.s("C->S=", (camera.global_position - socket.global_position).length())

func __CP() -> String:
	return pp.s("C->P=", (camera.global_position - pivot.global_position).length())

func __CF() -> String:
	return pp.s("C->F=", (camera.global_position - aim.global_position).length())

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
# Boom: vector from pivot (pivot/chest) to the camera. Now is free_boom / lock_boom
# Boom length: _default_len and _current_len.
# Pivot: the anchor to orbit around (pivot).
# Desired/ideal camera: socket (pre-collision point).
# Resolved/actual camera: camera after collision solver.
