extends RefCounted
class_name DodgeDirection


class _DirData:
	var speed: float
	var anim_id: String
	func _init(_speed: float, _anim_id: String):
		speed = _speed
		anim_id = _anim_id


enum Dir {
	NEUTRAL,
	FORWARD,
	BACKWARD,
	RIGHT,
	LEFT
	}


var _curr_dir: Dir = Dir.NEUTRAL
var _dir_data: Dictionary = {}


func _init(speed_r: float, anim_r: String, speed_l: float, anim_l: String, speed_f: float, anim_f: String, speed_b: float, anim_b: String):
	_dir_data = {
		Dir.NEUTRAL: _DirData.new(speed_f, anim_f), # NOTE: intentionally using forward dodge for now
		Dir.FORWARD: _DirData.new(speed_f, anim_f),
		Dir.BACKWARD: _DirData.new(speed_b, anim_b),
		Dir.RIGHT: _DirData.new(speed_r, anim_r),
		Dir.LEFT: _DirData.new(speed_l, anim_l),
	}


## Returns the world-space vector for the current dodge direction
func current_world_vector(player_basis: Basis) -> Vector3:
	match _curr_dir:
		Dir.NEUTRAL:
			return player_basis.z
		Dir.FORWARD:
			return player_basis.z
		Dir.BACKWARD:
			return -player_basis.z
		Dir.RIGHT:
			return -player_basis.x
		Dir.LEFT:
			return player_basis.x
	return Vector3.ZERO


func set_direction_simplified(dir: Direction.Dir):
	match dir:
		Direction.Dir.NEUTRAL:
			_curr_dir = Dir.NEUTRAL
		Direction.Dir.FORWARD:
			_curr_dir = Dir.FORWARD
		Direction.Dir.BACKWARD:
			_curr_dir = Dir.BACKWARD
		Direction.Dir.RIGHT, Direction.Dir.RIGHT_F, Direction.Dir.RIGHT_B:
			_curr_dir = Dir.RIGHT
		Direction.Dir.LEFT, Direction.Dir.LEFT_F, Direction.Dir.LEFT_B:
			_curr_dir = Dir.LEFT
		_: # unreachable
			_curr_dir = Dir.NEUTRAL

	
func get_curr_dir() -> Dir:
	return _curr_dir

func is_horizontal() -> bool:
	return _curr_dir == DodgeDirection.Dir.RIGHT or _curr_dir == DodgeDirection.Dir.LEFT

func get_curr_anim_id() -> String:
	return _dir_data[_curr_dir].anim_id


func get_curr_speed() -> float:
	return _dir_data[_curr_dir].speed


func get_all_anims() -> Array[String]:
	var anims: Array[String] = []
	for data in _dir_data.values():
		if not data.anim_id in anims:
			anims.append(data.anim_id)
	return anims


## helpers

func pp_curr_dir() -> String:
	return pp_dir_name(_curr_dir)


static func __both_in_group(dir_1, dir_2, group: Array) -> bool:
	return dir_1 in group and dir_2 in group


static func pp_dir_name(dir: Dir) -> String:
	return Dir.find_key(dir)
