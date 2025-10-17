extends RefCounted
class_name StrafeDirection

class _DirData:
	var speed: float
	var anim_id: String
	func _init(_speed: float, _anim_id: String):
		speed = _speed
		anim_id = _anim_id


enum Dir {
	LEFT, RIGHT,
	LEFT_F, RIGHT_F,
	LEFT_B, RIGHT_B
}


var curr_dir: Dir = Dir.RIGHT # default jic
var _dir_data: Dictionary = {}


func _init(speed_r: float, anim_r: String, speed_l: float, anim_l: String):
	_dir_data = {
		Dir.RIGHT: _DirData.new(speed_r, anim_r),
		Dir.RIGHT_F: _DirData.new(speed_r, anim_r),
		Dir.RIGHT_B: _DirData.new(speed_r, anim_r),
		Dir.LEFT: _DirData.new(speed_l, anim_l),
		Dir.LEFT_F: _DirData.new(speed_l, anim_l),
		Dir.LEFT_B: _DirData.new(speed_l, anim_l)
	}


func set_direction(dir: Dir):
	curr_dir = dir


func get_curr_anim_id() -> String:
	return _dir_data[curr_dir].anim_id


func get_curr_speed() -> float:
	return _dir_data[curr_dir].speed


func get_dir_int() -> int:
	match curr_dir:
		Dir.RIGHT, Dir.RIGHT_F, Dir.RIGHT_B:
			return 1
		Dir.LEFT, Dir.LEFT_F, Dir.LEFT_B:
			return -1
	return 0 # should not happen


func would_be_opposite_change(new_dir: Dir) -> bool:
	if curr_dir == new_dir: return false

	var left_variants = [Dir.LEFT, Dir.LEFT_F, Dir.LEFT_B]
	var right_variants = [Dir.RIGHT, Dir.RIGHT_F, Dir.RIGHT_B]

	var forward_variants = [Dir.LEFT_F, Dir.RIGHT_F]
	var backward_variants = [Dir.LEFT_B, Dir.RIGHT_B]

	if __both_in_group(curr_dir, new_dir, left_variants): return false
	if __both_in_group(curr_dir, new_dir, right_variants): return false
	if __both_in_group(curr_dir, new_dir, forward_variants): return false
	if __both_in_group(curr_dir, new_dir, backward_variants): return false

	return true


func would_be_slight_change(new_dir: Dir) -> bool:
	if curr_dir == new_dir:
		return false
	return not would_be_opposite_change(new_dir)


func get_all_anims() -> Array[String]:
	var anims: Array[String] = []
	for data in _dir_data.values():
		if not data.anim_id in anims:
			anims.append(data.anim_id)
	return anims


func detect_dir_from_input(input: InputPackage, on_enter: bool = false) -> Dir:
	var orbit_input = input.orbit_input
	var forward_input = input.forward_input
	var new_dir: Dir

	if orbit_input > 0.0: # Right Group
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
	
	if new_dir != curr_dir or on_enter:
		print_.lsm_action("StrafeDirection", pp.s("orbit/forward input", orbit_input, forward_input, "=>", new_dir))
	
	return new_dir


static func __both_in_group(dir_1, dir_2, group) -> bool:
	return dir_1 in group and dir_2 in group
