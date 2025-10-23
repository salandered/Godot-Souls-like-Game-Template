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

#
var reverse_data: ReverseData = ReverseData.new()

# experimental raw additions to use in client code
func is_running() -> bool:
	var r := PS.run in actions or PS.sprint in actions
	return r
	
var jump_key: KeyPress = null
#

# ```


func detect_strafe_dir() -> Direction.Dir:
	var dir: Direction.Dir

	if reverse_data.is_reversed():
		var _target_dir := reverse_data.target_dir
		var target_dir := Direction.from_vector(_target_dir)
		# print_.prefix("detect_strafe_dir", pp.s("reverse is true, orig target dir / result", _target_dir, Direction.name_(target_dir)))
		return target_dir
		
	if abs(orbit_input) < 0.01: # Pure Forward/Backward (no strafe input)
		if abs(forward_input) < 0.01:
			dir = Direction.Dir.NEUTRAL
		elif forward_input > 0.0:
			dir = Direction.Dir.FORWARD
		else:
			dir = Direction.Dir.BACKWARD
	elif orbit_input > 0.0: # Right Group
		if forward_input > 0.0:
			dir = Direction.Dir.RIGHT_F
		elif forward_input < 0.0:
			dir = Direction.Dir.RIGHT_B
		else:
			dir = Direction.Dir.RIGHT
	else: # Left Group
		if forward_input > 0.0:
			dir = Direction.Dir.LEFT_F
		elif forward_input < 0.0:
			dir = Direction.Dir.LEFT_B
		else:
			dir = Direction.Dir.LEFT

	return dir
# 

func _to_string() -> String:
	var parts := []
	parts.append("input_dir: %s" % input_direction)
	if not actions.is_empty():
		parts.append("actions: %s" % ", ".join(actions))
	parts.append(str(reverse_data))
	
	return "InputPackage(%s)" % ", ".join(parts)
