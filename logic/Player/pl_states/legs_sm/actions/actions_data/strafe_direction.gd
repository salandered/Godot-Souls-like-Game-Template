extends RefCounted
class_name StrafeDirection

class _DirData:
	var speed: float
	var anim_id: String
	func _init(_speed: float, _anim_id: String):
		speed = _speed
		anim_id = _anim_id


enum Dir {
	FORWARD,
	BACKWARD,
	RIGHT,
	RIGHT_F,
	RIGHT_B,
	LEFT,
	LEFT_F,
	LEFT_B
}


enum ChangeType {
	OPPOSITE,
	SLIGHT,
	SLIGHTEST,
	SAME
}


var _curr_dir: Dir = Dir.RIGHT # default jic
var _dir_data: Dictionary = {}


func _init(speed_r: float, anim_r: String, speed_l: float, anim_l: String, speed_f: float, anim_f: String, speed_b: float, anim_b: String):
	_dir_data = {
		Dir.FORWARD: _DirData.new(speed_f, anim_f),
		Dir.BACKWARD: _DirData.new(speed_b, anim_b),
		Dir.RIGHT: _DirData.new(speed_r, anim_r),
		Dir.RIGHT_F: _DirData.new(speed_r, anim_r),
		Dir.RIGHT_B: _DirData.new(speed_r, anim_r),
		Dir.LEFT: _DirData.new(speed_l, anim_l),
		Dir.LEFT_F: _DirData.new(speed_l, anim_l),
		Dir.LEFT_B: _DirData.new(speed_l, anim_l)
	}


func is_pure_vertical() -> bool:
	return _curr_dir in [Dir.FORWARD, Dir.BACKWARD]


func set_direction(dir: Dir):
	_curr_dir = dir


func get_curr_anim_id() -> String:
	return _dir_data[_curr_dir].anim_id


func get_curr_speed() -> float:
	return _dir_data[_curr_dir].speed


func get_dir_int() -> int:
	match _curr_dir:
		Dir.FORWARD:
			return 1
		Dir.BACKWARD:
			return -1
		Dir.RIGHT, Dir.RIGHT_F, Dir.RIGHT_B:
			return 1
		Dir.LEFT, Dir.LEFT_F, Dir.LEFT_B:
			return -1
	return 0 # should not happen


## sum is 28
static var all_dir_pairs = [
	# 180 OPPOSITE (most frequent)
	[Dir.FORWARD, Dir.BACKWARD, ChangeType.OPPOSITE],
	[Dir.RIGHT, Dir.LEFT, ChangeType.OPPOSITE],
	
	# 90 VERT STRAFE SPAM (frequent) (e.g W pressed A/D spams)
	[Dir.RIGHT_F, Dir.LEFT_F, ChangeType.SLIGHT],
	[Dir.RIGHT_B, Dir.LEFT_B, ChangeType.SLIGHT],

	# other 90
	[Dir.FORWARD, Dir.RIGHT, ChangeType.SLIGHT],
	[Dir.FORWARD, Dir.LEFT, ChangeType.SLIGHT],
	[Dir.BACKWARD, Dir.RIGHT, ChangeType.SLIGHT],
	[Dir.BACKWARD, Dir.LEFT, ChangeType.SLIGHT],
	
	# other 90
	[Dir.LEFT_F, Dir.LEFT_B, ChangeType.SLIGHT],
	[Dir.RIGHT_F, Dir.RIGHT_B, ChangeType.SLIGHT],

	# 45 SLIGHTEST
	[Dir.FORWARD, Dir.RIGHT_F, ChangeType.SLIGHTEST],
	[Dir.FORWARD, Dir.LEFT_F, ChangeType.SLIGHTEST],
	[Dir.BACKWARD, Dir.RIGHT_B, ChangeType.SLIGHTEST],
	[Dir.BACKWARD, Dir.LEFT_B, ChangeType.SLIGHTEST],
	[Dir.RIGHT, Dir.RIGHT_F, ChangeType.SLIGHTEST],
	[Dir.RIGHT, Dir.RIGHT_B, ChangeType.SLIGHTEST],
	[Dir.LEFT, Dir.LEFT_F, ChangeType.SLIGHTEST],
	[Dir.LEFT, Dir.LEFT_B, ChangeType.SLIGHTEST],

	# 135
	[Dir.FORWARD, Dir.RIGHT_B, ChangeType.OPPOSITE],
	[Dir.FORWARD, Dir.LEFT_B, ChangeType.OPPOSITE],
	[Dir.BACKWARD, Dir.RIGHT_F, ChangeType.OPPOSITE],
	[Dir.BACKWARD, Dir.LEFT_F, ChangeType.OPPOSITE],
	[Dir.RIGHT, Dir.LEFT_F, ChangeType.OPPOSITE],
	[Dir.RIGHT, Dir.LEFT_B, ChangeType.OPPOSITE],
	[Dir.LEFT, Dir.RIGHT_F, ChangeType.OPPOSITE],
	[Dir.LEFT, Dir.RIGHT_B, ChangeType.OPPOSITE],
	
	# 180 OPPOSITE (less frequent)
	[Dir.RIGHT_F, Dir.LEFT_B, ChangeType.OPPOSITE],
	[Dir.RIGHT_B, Dir.LEFT_F, ChangeType.OPPOSITE],
]


func would_be_change_of_type(new_dir: Dir) -> ChangeType:
	if _curr_dir == new_dir: return ChangeType.SAME

	for collection in all_dir_pairs:
		if __both_in_group(_curr_dir, new_dir, collection):
			return collection[2]

	return ChangeType.SAME # unreachable


func get_all_anims() -> Array[String]:
	var anims: Array[String] = []
	for data in _dir_data.values():
		if not data.anim_id in anims:
			anims.append(data.anim_id)
	return anims


func detect_dir_from_input(input_: InputPackage, on_enter: bool = false) -> Dir:
	var orbit_input = input_.orbit_input
	var forward_input = input_.forward_input
	var new_dir: Dir

	if abs(orbit_input) < 0.01: # Pure Forward/Backward (no strafe input)
		if forward_input > 0.0:
			new_dir = Dir.FORWARD
		elif forward_input < 0.0:
			new_dir = Dir.BACKWARD
		else:
			new_dir = _curr_dir # no input, keep current
	elif orbit_input > 0.0: # Right Group
		if forward_input > 0.0:
			new_dir = Dir.RIGHT_F
		elif forward_input < 0.0:
			new_dir = Dir.RIGHT_B
		else:
			new_dir = Dir.RIGHT
	else: # Left Group
		if forward_input > 0.0:
			new_dir = Dir.LEFT_F
		elif forward_input < 0.0:
			new_dir = Dir.LEFT_B
		else:
			new_dir = Dir.LEFT
	
	if new_dir != _curr_dir or on_enter:
		print_.lsm_action("StrafeDirection", pp.s("orbit/forward input", orbit_input, forward_input, "=>", pp_dir_name(new_dir)))
	
	return new_dir


func pp_curr_dir() -> String:
	return pp_dir_name(_curr_dir)


static func __both_in_group(dir_1, dir_2, group: Array) -> bool:
	return dir_1 in group and dir_2 in group

static func pp_dir_name(dir: Dir) -> String:
	return Dir.find_key(dir)
