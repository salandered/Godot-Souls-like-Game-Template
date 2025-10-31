@tool
@icon("res://-assets-/x_misc/x_icons/yellow/icon_visibility.png")
extends Node
class_name AreaAwareness

@onready var container: PlayerStatesContainer = %StatesContainer


@onready var player: Princess = $"../.."


var last_pushback_vector: Vector3 # todo: what
var last_input_package: InputPackage

# var locked_target: Node3D

enum LockState {
		ALL_UNLOCKED, # strafe cant be locked while camera unlocked => 3 states, not 4
		CAMERA_LOCKED_MOVE_UNLOCKED,
		ALL_LOCKED,
	}

var current_lock_state: LockState = LockState.ALL_UNLOCKED

@export var LOCKING_ANGLE := 30.0
@export var TARGET_LOCK_DISTANCE_SQUARED := 128.0
@onready var downcast := $Downcast as RayCast3D


func _decide_on_lock_state(new_input: InputPackage) -> LockState:
	# NOTE: camera info is more important that input
	var is_cam_locked := is_camera_locked()
	# if new_input.target_lock.any_tap():
		# __log_aware("~~~~we are in decide on lock with", new_input.target_lock)
	if not is_cam_locked:
		return LockState.ALL_UNLOCKED

	# next if camera is locked
	match current_lock_state:
		LockState.ALL_UNLOCKED:
			# __log_aware("~~~~return ALL_LOCKED", new_input.target_lock)
			return LockState.ALL_LOCKED
		
		LockState.ALL_LOCKED:
			if new_input.target_lock.double_tap:
				# __log_aware("~~~~return CAMERA_LOCKED_MOVE_UNLOCKED", new_input.target_lock)
				return LockState.CAMERA_LOCKED_MOVE_UNLOCKED

		LockState.CAMERA_LOCKED_MOVE_UNLOCKED:
			if new_input.target_lock.double_tap:
				# __log_aware("~~~~return ALL_LOCKED", new_input.target_lock)
				return LockState.ALL_LOCKED

	
	return current_lock_state

func contextualize(new_input: InputPackage) -> InputPackage:
	current_lock_state = _decide_on_lock_state(new_input)

	if current_lock_state == LockState.ALL_LOCKED:
		_translate_to_strafe(new_input)
	return new_input


# const TO_ROLL_MAP = {
# 	PS.jump_sprint: PS.roll,
# }


const TO_STRAFE_MAP = {
	PS.run: PS.strafe,
	PS.jump_sprint: PS.dodge,
}


func _apply_translation(new_input: InputPackage, translation_map: Dictionary):
	for i in range(new_input.actions.size()):
		var current_action := new_input.actions[i]
		
		if current_action in translation_map:
			new_input.actions[i] = translation_map[current_action]


func _translate_to_strafe(new_input: InputPackage):
	_apply_translation(new_input, TO_STRAFE_MAP)


func is_camera_locked() -> bool:
	return player.fancy_camera.is_locked_state()

# func is_target_locked() -> bool:
# 	return locked_target != null

func get_camera_locked_target() -> Node3D:
	return player.fancy_camera.locked_target

# func get_locked_target() -> Node3D:
# 	return locked_target

		
# func drop_target():
# 	camera_locked_target = null

var extreme_landing_height: float = 1.1
var landing_height: float = 0.6
var tolerate_height: float = 0.1


func floor_dist_under_extreme_landing_height(_log: bool = true) -> bool:
	var _r = get_floor_distance() <= extreme_landing_height
	if _log: __log_floor_dist("<= land height", extreme_landing_height, "? =>", _r)
	return _r


func floor_dist_under_landing_height(_log: bool = true) -> bool:
	var _r = get_floor_distance() <= landing_height
	if _log: __log_floor_dist("<= land height", landing_height, "? =>", _r)
	return _r


func floor_dist_under_tolerated_height(_log: bool = true) -> bool:
	var _r = get_floor_distance() <= tolerate_height
	if _log: __log_floor_dist("<= tolerate height", tolerate_height, "? =>", _r)
	return _r


func get_floor_distance() -> float:
	if downcast.is_colliding():
		#__log_aware('-------------- colliding')
		return downcast.global_position.distance_to(downcast.get_collision_point())
	#__log_aware('-------------- not colliding')
	return Constants.BIG_MEANINGLESS_NUMBER


func find_target() -> Node:
	var all_targets := get_tree().get_nodes_in_group("targetable")
	# print_.aware_target("POSSIBLE targets: ", all_targets.map(func(t): return t.label))
	var candidates: Array[Node] = []
	for target in all_targets:
		if _is_good_candidate(target):
			candidates.append(target)
	
	if not candidates.is_empty():
		# __log_aware("    > candidates before sorting: ", candidates.map(func(t): return t.label))
		_sort_targets_by_player_distance(candidates)
		# __log_aware("    > candidates after sorting: ", candidates.map(func(t): return t.label))
		return candidates[0]
	# __log_aware("   > nothing ")
	return null


func camera_focus_further_than_squared(node: Node3D, distance: float) -> bool:
	var camera_focus_pos := player.camera_focus.global_position
	return camera_focus_pos.distance_squared_to(node.global_position) > distance


func _is_good_candidate(target: Node3D) -> bool:
	# TODO: consider raycast from the cam or pl to the target to ensure there's no obstacle
	var half_fov := deg_to_rad(30) # narrows to ±30°
	var min_dot := cos(half_fov)

	if not player.fancy_camera.camera.is_position_in_frustum(target.global_position):
		# __log_candidate(target, "frustum")
		return false
	if camera_focus_further_than_squared(target, TARGET_LOCK_DISTANCE_SQUARED):
		# _print.call(target, "distance")
		return false

	var camera_to_target := (target.global_position - player.fancy_camera.camera.global_transform.origin).normalized()
	var camera_forward := -player.fancy_camera.camera.global_transform.basis.z
	if camera_forward.dot(camera_to_target) < min_dot:
		# _print.call(target, "angle between camera forward and target")
		return false

	var player_to_target := (target.global_position - player.global_transform.origin).normalized()
	var player_forward := player.global_transform.basis.z
	# if player_forward.dot(player_to_target) < 0:
	# 	# _print.call(target, "behind player")
	# 	return false
	return true


func _sort_targets_by_player_distance(targets: Array) -> void:
	targets.sort_custom(
			func(a, b): \
				return a.global_position.distance_squared_to(player.global_position) \
				< b.global_position.distance_squared_to(player.global_position)
		)


# region: LOG

func __log_aware(...parts: Array):
		print_.aware("", pp.list_(parts))


func __log_candidate(target, reason):
	print_.aware_target("candidate" + em.gray_x, pp.s("target.lbl:", target.label, "Reason:", reason))


func __log_floor_dist(...parts: Array):
	print_.aware("", pp.s("floor_dist", get_floor_distance(), pp.list_(parts)))

# endregion
