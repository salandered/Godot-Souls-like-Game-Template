extends Node
class_name AreaAwareness

@onready var container: PlayerStatesContainer = %StatesContainer


@onready var player = $"../.."
var last_pushback_vector: Vector3
var last_input_package: InputPackage
var locked_target: Node3D
var strafe_lock: bool = false
var camera_just_locked: bool = false

enum LockState {
		ALL_UNLOCKED, # strafe cant be locked while camera unlocked
		CAMERA_LOCKED_STRAFE_UNLOCKED,
		ALL_LOCKED,
	}

var current_lock_state: LockState = LockState.ALL_UNLOCKED

@export var LOCKING_ANGLE = 30
@export var TARGET_LOCK_DISTANCE_SQUARED = 128
@onready var downcast = $Downcast as RayCast3D

func _choose_lock_state() -> LockState:
	if current_lock_state == LockState.ALL_UNLOCKED:
		if is_camera_locked():
			# may change to ALL_LOCKED
			return LockState.CAMERA_LOCKED_STRAFE_UNLOCKED

	elif current_lock_state == LockState.CAMERA_LOCKED_STRAFE_UNLOCKED:
		if not is_camera_locked():
			return LockState.ALL_UNLOCKED
		if last_input_package.target_lock_long_pressed:
			return LockState.ALL_LOCKED

	elif current_lock_state == LockState.ALL_LOCKED:
		if not is_camera_locked():
			return LockState.ALL_UNLOCKED

		if last_input_package.target_lock_long_pressed:
			return LockState.CAMERA_LOCKED_STRAFE_UNLOCKED
	
	return current_lock_state

func contextualize(new_input: InputPackage) -> InputPackage:
	current_lock_state = _choose_lock_state()

	if current_lock_state == LockState.ALL_LOCKED:
		_translate_to_strafe(new_input)
	return new_input

var to_strafe = {
		PlayerState.run: PlayerState.strafe,
		PlayerState.idle: PlayerState.strafe
	}


func _translate_to_strafe(new_input: InputPackage):
	# print("AA actions ", new_input.actions)
	new_input.actions.sort_custom(container.states_priority_sort)
	var prioritized_state: String = new_input.actions[0] # safe
	var translated_to_strafe = to_strafe.get(prioritized_state)

	if translated_to_strafe:
		# print("   AA ", prioritized_state, " -> ", translated_to_strafe)
		new_input.actions.erase(prioritized_state)
		new_input.actions.append(translated_to_strafe)
		# print("   AA actions result: ", new_input.actions)

func get_floor_distance() -> float:
	if downcast.is_colliding():
		return downcast.global_position.distance_to(downcast.get_collision_point())
	return 999999


func is_camera_locked() -> bool:
	return player.fancy_camera.current_state is LockedCameraState

func is_target_locked() -> bool:
	return locked_target != null

func get_camera_locked_target() -> Node3D:
	return player.fancy_camera.locked_target

func get_locked_target() -> Node3D:
	return locked_target

		
# func drop_target():
# 	camera_locked_target = null


func find_target():
	var all_targets = get_tree().get_nodes_in_group("targetable")
	# print("POSSIBLE targets: ", all_targets.map(func(t): return t.label))
	var candidates := []
	for target in all_targets:
		if _good_candidate(target):
			candidates.append(target)
	
	if not candidates.is_empty():
		# print("    > candidates before sorting: ", candidates.map(func(t): return t.label))
		_sort_targets_by_player_distance(candidates)
		# print("    > candidates after sorting: ", candidates.map(func(t): return t.label))
		return candidates[0]
	# print("   > nothing ")
	return null

func camera_focus_further_than(node: Node3D, distance: float) -> bool:
	var camera_focus_pos = player.camera_focus.global_position
	return camera_focus_pos.distance_squared_to(node.global_position) > distance


func _good_candidate(target: Node3D) -> bool:
	# TODO: may be add raycast from the camera or player to the target to ensure there's no obstacle in the way
	var _print = func(label, reason): print("    x ", label, " ", reason)
	# print(LOCKING_ANGLE)
	var half_fov = deg_to_rad(30) # narrows to ±30°
	var min_dot = cos(half_fov)

	if not player.fancy_camera.camera.is_position_in_frustum(target.global_position):
		# _print.call(target.label, "frustum")
		return false
	if camera_focus_further_than(target, TARGET_LOCK_DISTANCE_SQUARED):
		# _print.call(target.label, "distance")
		return false

	var camera_to_target = (target.global_position - player.fancy_camera.camera.global_transform.origin).normalized()
	var camera_forward = - player.fancy_camera.camera.global_transform.basis.z
	if camera_forward.dot(camera_to_target) < min_dot:
		# _print.call(target.label, "angle between camera forward and target")
		return false

	var player_to_target = (target.global_position - player.global_transform.origin).normalized()
	var player_forward = player.global_transform.basis.z
	if player_forward.dot(player_to_target) < 0:
		# _print.call(target.label, "behind player")
		return false
	
	return true

func _sort_targets_by_player_distance(targets: Array) -> void:
	targets.sort_custom(
			func(a, b): \
				return a.global_position.distance_to(player.global_position) \
				< b.global_position.distance_to(player.global_position)
		)
