extends Node
class_name AreaAwareness


@onready var player = $"../.."
var last_pushback_vector: Vector3
var last_input_package: InputPackage

var locked_target: Node3D


@export var LOCKING_ANGLE = 30
@export var TARGET_LOCK_DISTANCE_SQUARED = 128
@onready var downcast = $Downcast as RayCast3D

func get_floor_distance() -> float:
	if downcast.is_colliding():
		return downcast.global_position.distance_to(downcast.get_collision_point())
	return 999999


func is_target_locked() -> bool:
	return locked_target != null

func lock_target() -> Node3D:
	locked_target = _find_target()
		# print("		fc.locked_target ", locked_target)
		# print("LOCK SUCCESFULL")
	return locked_target
		# print("xLOCK NOT")
		

func drop_target():
	locked_target = null


func _find_target():
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

func _good_candidate(target: Node3D) -> bool:
	# TODO: may be add raycast from the camera or player to the target to ensure there's no obstacle in the way
	var _print = func(label, reason): print("    x ", label, " ", reason)
	var half_fov = deg_to_rad(LOCKING_ANGLE) # narrows to ±30°
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


func camera_focus_further_than(node: Node3D, distance: float) -> bool:
	var camera_focus_pos = player.camera_focus.global_position
	return camera_focus_pos.distance_squared_to(node.global_position) > distance
