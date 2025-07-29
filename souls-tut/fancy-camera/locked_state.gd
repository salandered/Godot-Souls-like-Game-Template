extends CameraState
class_name LockedCameraState


@onready var fc: FancyCamera = $".."

var look_at_: Node3D
var offset: Vector3


var target_offset: Vector3
var offset_transition_t := 0.0

func _ready():
	look_at_ = fc.look_at_
	print("LockedCameraState ready()")
	print("		look_at_ ", look_at_)


func update(delta: float) -> void:
	# In locked state we try to position camera in a way that keeps the player between the Camera Nest and the target. 
	# print(offset_transition_t)
	if offset_transition_t < 1.0:
		offset_transition_t = min(1.0, offset_transition_t + delta / fc.OFFSET_BLEND_DURATION_ON_LOCK)
		offset = offset.lerp(target_offset, offset_transition_t)
	
	_move_focus_point()
	_move_camera_nest()
	_move_camera()
	_check_distance()

func _move_focus_point() -> void:
	var new_focus = lerp(fc.focus.global_position, look_at_.global_position, fc.FOCUS_FOLLOWING_WEIGHT)
	if offset_transition_t >= 1.0:
		_rotate_offset_locked(new_focus)
	fc.focus.global_position = new_focus

func _rotate_offset_locked(new_focus: Vector3) -> void:
	# counts the direction from target to player, then builds the new offset Vector with this direction from the ground up, changing its X and Z coordinates and saving its Y coordinate.
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var center_projected: Vector3 = fc.player.camera_focus.global_position
	center_projected.y = 0
	var offset_xz_length := sqrt(offset.x * offset.x + offset.z * offset.z)
	var new_offset := (center_projected - new_focus_projected).normalized() * offset_xz_length
	new_offset.y = offset.y
	offset = new_offset

func _move_camera_nest() -> void:
	fc.mount.global_position = lerp(
		fc.mount.global_position,
		fc.player.camera_focus.global_position,
		fc.CAM_MOUNT_FOLLOWING_WEIGHT
	)
	fc.nest.global_position = lerp(
		fc.nest.global_position,
		fc.mount.global_position + offset,
		fc.CAM_NEST_FOLLOWING_WEIGHT
	)

func _move_camera() -> void:
	if not fc.camera.position.is_equal_approx(fc.nest.position):
		fc.camera.position = fc.nest.position
	fc.camera.look_at(fc.focus.global_position)

func _check_distance() -> void:
	# checks if the distance between the player and target is too big and drops the target if triggered
	if fc.camera_focus_further_than(fc.locked_target, fc.TARGET_DROP_DISTANCE_SQUARED):
		# print("dropping ", distance, " ", TARGET_DROP_DISTANCE_SQUARED)
		_drop_target()

func input_target_lock():
	_drop_target()

func _drop_target() -> void:
	print("DROP started")
	fc.free_camera.look_at_ = fc.player.camera_focus
	# offset reassignment is to avoid the camera leap, as the last offset the free camera remembers is the offset when it passed the priority to the locked state
	# fc.free_camera.offset = fc.nest.global_position - fc.mount.global_position
	var restored_offset = fc.nest.global_position - fc.mount.global_position
	restored_offset = restored_offset.normalized() * fc.free_camera.offset.length()
	fc.free_camera.offset = restored_offset
	fc.current_state = fc.free_camera
	fc.is_target_locked = false
	fc.locked_target = fc.nest
	print("		fc.locked_target ", fc.locked_target)
	print("DROP ended")

func input_mouse_movement(d_x: float, d_y: float) -> void:
	# nothing to do in locked state
	pass
