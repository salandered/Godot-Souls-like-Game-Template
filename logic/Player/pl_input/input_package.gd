extends Resource
class_name InputPackage

var input_direction: Vector2

# NOTE: for now actions contains player states like PS.run
var actions: Array[String]
var combat_actions: Array[String]

class TargetLockInput:
	## NOTE: all are mutually exclusive
	var tap_waiting: bool = false
	var tap: bool = false
	var double_tap: bool = false
	
	func no_tap() -> bool:
		return not (tap_waiting or tap or double_tap)

	func any_tap() -> bool:
		return tap_waiting or tap or double_tap
	
	func tap_or_double_tap() -> bool:
		return tap or double_tap

	func _to_string() -> String:
		return pp.s(" (", tap_waiting, tap, double_tap, ")")

var target_lock: TargetLockInput = TargetLockInput.new()

# Fancy camera
var forward_input := 0.0
var orbit_input := 0.0

# 

var reverse_data: ReverseData = ReverseData.new()

# 
func _to_string() -> String:
	var parts = []
	parts.append("input_dir: %s" % input_direction)
	if not actions.is_empty():
		parts.append("actions: %s" % ", ".join(actions))
	parts.append(str(reverse_data))
	
	return "InputPackage(%s)" % ", ".join(parts)
