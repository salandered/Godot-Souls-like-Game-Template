class_name PlayerLookAtManager
extends BaseLookAtManager


@export var modifier: LookAtHeadModifier3D
@export var scan_radius: float = 10.0
@export var scan_interval: float = 0.5


var _timer: float = 0.0


func __hard_dependencies() -> Array:
	return [
		modifier,
		_my_marker
	]


func initialise(target_marker_: LookAtCharacterMarker, my_marker_: LookAtCharacterMarker) -> void:
	_my_marker = my_marker_
	if not __perform_validation():
		__log_warn_soft("won't be working")
		set_process(false)
	else:
		__log_("_ready", "Scan radius", scan_radius)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		_timer = scan_interval
		_scan_for_targets()


func _scan_for_targets() -> void:
	if not modifier: return
	
	if _target_marker and not is_instance_valid(_target_marker):
		__log_("🕵🏻", "_curr_target_marker is not valid, gonna clear")
		_clear_target()
	if _target_marker and _target_marker.is_queued_for_deletion():
		__log_("🕵🏻", "_curr_target_marker is queued_for_deletion, gonna clear")
		_clear_target()

	var _candidates := get_tree().get_nodes_in_group(Groups.Marker.LOOK_AT)
	var candidate_markers: Array[LookAtCharacterMarker] = []
	for item: Node in _candidates:
		if item is LookAtCharacterMarker:
			candidate_markers.append(item)

	var closest_marker: LookAtCharacterMarker = null
	var sq_closest_dist := u.fpow2(scan_radius)
	var my_pos := _my_marker.global_position
	
	
	for marker: LookAtCharacterMarker in candidate_markers:
		if not marker.active:
			continue
		if marker == _my_marker:
			continue
			
		var sq_dist := my_pos.distance_squared_to(marker.global_position)
		
		if sq_dist < sq_closest_dist:
			sq_closest_dist = sq_dist
			closest_marker = marker

	if closest_marker:
		if closest_marker != _target_marker:
			__log_("🕵🏻", "Target switch to", closest_marker.name, closest_marker)
			_apply_new_target(closest_marker)
		else:
			__log_("🕵🏻", "Same target")
	else:
		if _target_marker:
			__log_("🕵🏻", "Lost target")
			_clear_target()
		else:
			__log_("🕵🏻", "No target found")


func _apply_new_target(marker: LookAtCharacterMarker) -> void:
	_target_marker = marker
	
	modifier.set_marker(marker)
	modifier.set_to_work(true)


func _clear_target() -> void:
	__log_("_curr_target_marker is cleared")
	_target_marker = null
	modifier.set_to_work(false)


func __LOG_B() -> bool:
	return false