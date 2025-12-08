extends RefCounted
class_name StrafeDirection

class _DirData:
	var speed: float
	var anim_id: String
	func _init(_speed: float, _anim_id: String):
		speed = _speed
		anim_id = _anim_id


var _curr_dir: Direction.Dir = Direction.Dir.NEUTRAL
var _dir_data: Dictionary[Direction.Dir, _DirData] = {}


func _init(speed_r: float, anim_r: String, speed_l: float, anim_l: String, speed_f: float, anim_f: String, speed_b: float, anim_b: String, anim_idle: String):
	_dir_data = {
		Direction.Dir.NEUTRAL: _DirData.new(0.0, anim_idle), # this anim probably would never play
		Direction.Dir.FORWARD: _DirData.new(speed_f, anim_f),
		Direction.Dir.BACKWARD: _DirData.new(speed_b, anim_b),
		Direction.Dir.RIGHT: _DirData.new(speed_r, anim_r),
		Direction.Dir.RIGHT_F: _DirData.new(speed_r, anim_r),
		Direction.Dir.RIGHT_B: _DirData.new(speed_r, anim_r),
		Direction.Dir.LEFT: _DirData.new(speed_l, anim_l),
		Direction.Dir.LEFT_F: _DirData.new(speed_l, anim_l),
		Direction.Dir.LEFT_B: _DirData.new(speed_l, anim_l)
	}


func is_pure_vertical() -> bool:
	return _curr_dir in [Direction.Dir.FORWARD, Direction.Dir.BACKWARD]


func set_direction(dir: Direction.Dir):
	_curr_dir = dir


func get_curr_dir() -> Direction.Dir:
	return _curr_dir


func get_curr_anim_id() -> String:
	return _dir_data[_curr_dir].anim_id


func get_curr_speed() -> float:
	return _dir_data[_curr_dir].speed


func get_dir_int() -> int:
	match _curr_dir:
		Direction.Dir.FORWARD:
			return 1
		Direction.Dir.BACKWARD:
			return -1
		Direction.Dir.RIGHT, Direction.Dir.RIGHT_F, Direction.Dir.RIGHT_B:
			return 1
		Direction.Dir.LEFT, Direction.Dir.LEFT_F, Direction.Dir.LEFT_B:
			return -1
	return 0 # should not happen


func get_all_anim_ids() -> Array[String]:
	var anims: Array[String] = []
	for data in _dir_data.values():
		if not data.anim_id in anims:
			anims.append(data.anim_id)
	return anims


func would_be_change_of_type(new_dir: Direction.Dir) -> DirPairs.ChangeType:
	if _curr_dir == new_dir: return DirPairs.ChangeType.SAME
	if _curr_dir == Direction.Dir.NEUTRAL or new_dir == Direction.Dir.NEUTRAL:
		return DirPairs.ChangeType.SAME # or SLIGHTEST

	# prints(Direction.full_name_(_curr_dir), Direction.full_name_(new_dir))
	var r := DirPairs.get_change_type(_curr_dir, new_dir)
	if r == -1:
		r = DirPairs.get_change_type(new_dir, _curr_dir)

	if r != -1:
		return r
	else: # should be unreachable
		print_.warn(true, "not found dirs in DirPairs!", "", "return SAME", _curr_dir, new_dir)
		return DirPairs.ChangeType.SAME


static func __both_in_group(dir_1, dir_2, group: Array) -> bool:
	return dir_1 in group and dir_2 in group


## helpers

func pp_curr_dir() -> String:
	return pp_dir_name(_curr_dir)

static func pp_dir_name(dir: Direction.Dir) -> String:
	return Direction.name_(dir)
