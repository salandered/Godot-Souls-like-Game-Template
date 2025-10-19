extends RefCounted
class_name StrafeDirection

class _DirData:
	var speed: float
	var anim_id: String
	func _init(_speed: float, _anim_id: String):
		speed = _speed
		anim_id = _anim_id


enum ChangeType {
	OPPOSITE,
	SLIGHT,
	SLIGHTEST,
	SAME
}


var _curr_dir: StrafeDir.E = StrafeDir.E.RIGHT # default jic
var _dir_data: Dictionary = {}


func _init(speed_r: float, anim_r: String, speed_l: float, anim_l: String, speed_f: float, anim_f: String, speed_b: float, anim_b: String):
	_dir_data = {
		StrafeDir.E.FORWARD: _DirData.new(speed_f, anim_f),
		StrafeDir.E.BACKWARD: _DirData.new(speed_b, anim_b),
		StrafeDir.E.RIGHT: _DirData.new(speed_r, anim_r),
		StrafeDir.E.RIGHT_F: _DirData.new(speed_r, anim_r),
		StrafeDir.E.RIGHT_B: _DirData.new(speed_r, anim_r),
		StrafeDir.E.LEFT: _DirData.new(speed_l, anim_l),
		StrafeDir.E.LEFT_F: _DirData.new(speed_l, anim_l),
		StrafeDir.E.LEFT_B: _DirData.new(speed_l, anim_l)
	}


func is_pure_vertical() -> bool:
	return _curr_dir in [StrafeDir.E.FORWARD, StrafeDir.E.BACKWARD]


func set_direction(dir: StrafeDir.E):
	_curr_dir = dir


func get_curr_dir() -> StrafeDir.E:
	return _curr_dir


func get_curr_anim_id() -> String:
	return _dir_data[_curr_dir].anim_id


func get_curr_speed() -> float:
	return _dir_data[_curr_dir].speed


func get_dir_int() -> int:
	match _curr_dir:
		StrafeDir.E.FORWARD:
			return 1
		StrafeDir.E.BACKWARD:
			return -1
		StrafeDir.E.RIGHT, StrafeDir.E.RIGHT_F, StrafeDir.E.RIGHT_B:
			return 1
		StrafeDir.E.LEFT, StrafeDir.E.LEFT_F, StrafeDir.E.LEFT_B:
			return -1
	return 0 # should not happen


func get_all_anims() -> Array[String]:
	var anims: Array[String] = []
	for data in _dir_data.values():
		if not data.anim_id in anims:
			anims.append(data.anim_id)
	return anims


## sum is 28
static var all_dir_pairs = [
	# todo: some hash
	# 180 OPPOSITE (most frequent)
	[StrafeDir.E.FORWARD, StrafeDir.E.BACKWARD, ChangeType.OPPOSITE],
	[StrafeDir.E.RIGHT, StrafeDir.E.LEFT, ChangeType.OPPOSITE],
	
	# 90 VERT STRAFE SPAM (frequent) (e.g W pressed A/D spams)
	[StrafeDir.E.RIGHT_F, StrafeDir.E.LEFT_F, ChangeType.SLIGHT],
	[StrafeDir.E.RIGHT_B, StrafeDir.E.LEFT_B, ChangeType.SLIGHT],

	# other 90
	[StrafeDir.E.FORWARD, StrafeDir.E.RIGHT, ChangeType.SLIGHT],
	[StrafeDir.E.FORWARD, StrafeDir.E.LEFT, ChangeType.SLIGHT],
	[StrafeDir.E.BACKWARD, StrafeDir.E.RIGHT, ChangeType.SLIGHT],
	[StrafeDir.E.BACKWARD, StrafeDir.E.LEFT, ChangeType.SLIGHT],
	
	# other 90
	[StrafeDir.E.LEFT_F, StrafeDir.E.LEFT_B, ChangeType.SLIGHT],
	[StrafeDir.E.RIGHT_F, StrafeDir.E.RIGHT_B, ChangeType.SLIGHT],

	# 45 SLIGHTEST
	[StrafeDir.E.FORWARD, StrafeDir.E.RIGHT_F, ChangeType.SLIGHTEST],
	[StrafeDir.E.FORWARD, StrafeDir.E.LEFT_F, ChangeType.SLIGHTEST],
	[StrafeDir.E.BACKWARD, StrafeDir.E.RIGHT_B, ChangeType.SLIGHTEST],
	[StrafeDir.E.BACKWARD, StrafeDir.E.LEFT_B, ChangeType.SLIGHTEST],
	[StrafeDir.E.RIGHT, StrafeDir.E.RIGHT_F, ChangeType.SLIGHTEST],
	[StrafeDir.E.RIGHT, StrafeDir.E.RIGHT_B, ChangeType.SLIGHTEST],
	[StrafeDir.E.LEFT, StrafeDir.E.LEFT_F, ChangeType.SLIGHTEST],
	[StrafeDir.E.LEFT, StrafeDir.E.LEFT_B, ChangeType.SLIGHTEST],

	# 135
	[StrafeDir.E.FORWARD, StrafeDir.E.RIGHT_B, ChangeType.OPPOSITE],
	[StrafeDir.E.FORWARD, StrafeDir.E.LEFT_B, ChangeType.OPPOSITE],
	[StrafeDir.E.BACKWARD, StrafeDir.E.RIGHT_F, ChangeType.OPPOSITE],
	[StrafeDir.E.BACKWARD, StrafeDir.E.LEFT_F, ChangeType.OPPOSITE],
	[StrafeDir.E.RIGHT, StrafeDir.E.LEFT_F, ChangeType.OPPOSITE],
	[StrafeDir.E.RIGHT, StrafeDir.E.LEFT_B, ChangeType.OPPOSITE],
	[StrafeDir.E.LEFT, StrafeDir.E.RIGHT_F, ChangeType.OPPOSITE],
	[StrafeDir.E.LEFT, StrafeDir.E.RIGHT_B, ChangeType.OPPOSITE],
	
	# 180 OPPOSITE (less frequent)
	[StrafeDir.E.RIGHT_F, StrafeDir.E.LEFT_B, ChangeType.OPPOSITE],
	[StrafeDir.E.RIGHT_B, StrafeDir.E.LEFT_F, ChangeType.OPPOSITE],
]


func would_be_change_of_type(new_dir: StrafeDir.E) -> ChangeType:
	if _curr_dir == new_dir: return ChangeType.SAME

	for collection in all_dir_pairs:
		if __both_in_group(_curr_dir, new_dir, collection):
			return collection[2]

	return ChangeType.SAME # unreachable


## helpers

func pp_curr_dir() -> String:
	return pp_dir_name(_curr_dir)


static func __both_in_group(dir_1, dir_2, group: Array) -> bool:
	return dir_1 in group and dir_2 in group


static func pp_dir_name(dir: StrafeDir.E) -> String:
	return StrafeDir.name_(dir)
