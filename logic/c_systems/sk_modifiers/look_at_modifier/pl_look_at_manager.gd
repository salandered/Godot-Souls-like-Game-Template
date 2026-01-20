extends NodeSystem
class_name PlayerLookAtManager

@export var me: Princess
@export var modifier: LookAtHeadModifier3D
@export var scan_radius: float = 10.0
@export var scan_interval: float = 0.5
@export var __debug_scanning: bool = false

var _timer: float = 0.0
var _current_target_char: Node3D


func __hard_dependencies() -> Array[Object]:
	return [
		modifier,
		me
		]


func _ready() -> void:
	if not __perform_validation():
		__log_warn_soft("Validation failed", "_ready")
		set_process(false)
	else:
		__log_("_ready", "Scan radius", scan_radius, "Interval", scan_interval)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		_timer = scan_interval
		_scan_for_targets()


func _scan_for_targets() -> void:
	if not modifier: return
	
	if __debug_scanning:
		__log_("--- Scan Start ---")
	
	if _current_target_char and not is_instance_valid(_current_target_char):
		__log_warn_soft("Target invalidated", "_scan_for_targets", "Clearing", _current_target_char)
		_clear_target()

	var candidates := get_tree().get_nodes_in_group(Groups.Chars.BASE_CHARACTER)
	var closest_char: Node3D = null
	var closest_dist: float = scan_radius
	var my_pos = me.global_position
	
	if __debug_scanning:
		__log_("Candidates found:", candidates.size())
	
	for char_node: Node in candidates:
		if char_node is not Node3D or char_node == me:
			continue
		
		var casted_node := char_node as Node3D
		var dist = my_pos.distance_to(casted_node.global_position)
		var has_marker = _has_valid_marker(casted_node)
		
		if __debug_scanning:
			__log_("Checking:", casted_node.name, "Dist:", dist, "Valid Marker:", has_marker)
		
		if dist < closest_dist:
			if has_marker:
				closest_dist = dist
				closest_char = casted_node

	if closest_char:
		# If we found a valid closest character
		if closest_char != _current_target_char:
			__log_("Target switch", "Old:", _current_target_char, "New:", closest_char)
			_apply_new_target(closest_char)
		elif __debug_scanning:
			# We are sticking to the same target
			__log_("Keeping current target", _current_target_char.name)
	else:
		# No valid character found in range
		if _current_target_char:
			__log_("No target in range", "Clearing current")
			_clear_target()
		elif __debug_scanning:
			__log_("No targets found")


# Helper to check validity without fully applying yet
func _has_valid_marker(node: Node3D) -> bool:
	return _find_marker_in(node) != null


func _apply_new_target(char_node: Node3D) -> void:
	var marker := _find_marker_in(char_node)
	
	if marker:
		__log_("Applying Target", char_node.name)
		_current_target_char = char_node
		modifier.initialise(marker, true)
		modifier.set_to_work(true)
	else:
		__log_warn("Missing marker on apply", "_apply_new_target", "Aborting", char_node)


func _clear_target() -> void:
	if __debug_scanning:
		__log_("Clearing Target")
	_current_target_char = null
	modifier.set_to_work(false)


func _find_marker_in(node: Node3D) -> LookAtCharacterMarker:
	if node is LookAtCharacterMarker:
		return node

	if node is BaseCharacter:
		var casted: BaseCharacter = node
		return casted.get_look_at_char_marker()
	return null


##


func __LOG_B() -> bool:
	return false
