extends PlayerState


@export var movement_multiplier: float = 2

func update(_input: InputPackage, delta: float):
	u.safe_look_at(player, player.global_position + area_awareness.last_pushback_vector)
	
	var delta_pos = current_action.get_root_position_delta(delta)
	delta_pos.y = 0
	player.velocity = (player.get_quaternion() * delta_pos / delta) * movement_multiplier
	if not player.is_on_floor():
		player.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	# player.move_and_slide()

# extends CameraState
# class_name LockedCameraState


@onready var fc: FancyCamera

var look_at_: Node3D
var offset: Vector3


var target_offset: Vector3
var offset_transition_t := 0.0

# func _ready():
# 	look_at_ = fc.look_at_
# 	print("LockedCameraState ready()")
# 	print("		look_at_ ", look_at_)


func AAupdate(delta: float) -> void:
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
	var new_focus = lerp(fc.focus.global_position, look_at_.global_position, fc.LOCKED_FOCUS_TARGET_WEIGHT)
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
		fc.FREE_MOUNT_CHEST_WEIGHT
	)
	fc.nest.global_position = lerp(
		fc.nest.global_position,
		fc.mount.global_position + offset,
		fc.FREE_NEST_MOUNT_WEIGHT
	)

func _move_camera() -> void:
	var mount_pos := fc.mount.global_position
	var nest_pos := fc.nest.global_position
	var space_state := fc.camera.get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(mount_pos, nest_pos)
	query.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
	query.collision_mask = fc.SPRING_ARM_COLLISION_MASK

	var result = space_state.intersect_ray(query)

	var final_pos := nest_pos
	if result:
		var hit_pos = result.position + result.normal * 0.05
		var max_dist = (nest_pos - mount_pos).length()
		var actual_dist = (hit_pos - mount_pos).length()
		if actual_dist < max_dist:
			final_pos = hit_pos

	fc.camera.global_position = final_pos
	u.safe_look_at(fc.camera, fc.focus.global_position)

func _check_distance() -> void:
	# checks if the distance between the player and target is too big and drops the target if triggered
	if fc.player.model.area_awareness.camera_focus_further_than(fc.locked_target, fc.TARGET_DROP_DISTANCE_SQUARED):
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
	fc.locked_target = fc.nest
	print("		fc.locked_target ", fc.locked_target)
	print("DROP ended")

func input_mouse_movement(d_x: float, d_y: float) -> void:
	# nothing to do in locked state
	pass
