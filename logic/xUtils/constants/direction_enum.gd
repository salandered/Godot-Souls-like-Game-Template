extends RefCounted
class_name Direction


enum Dir {
	NEUTRAL, # 0
	FORWARD, # 1
	BACKWARD,
	RIGHT,
	RIGHT_F,
	RIGHT_B, # 5
	LEFT,
	LEFT_F, # 7
	LEFT_B
}

static func name_(dir: Dir) -> String:
	return Dir.find_key(dir)


static func full_name_(dir: Dir) -> String:
	return pp.in_q(str(dir) + "|" + str(Dir.find_key(dir)))


static func simplify(dir: Dir) -> Dir:
	match dir:
		Dir.NEUTRAL: return Dir.NEUTRAL
		Dir.FORWARD: return Dir.FORWARD
		Dir.BACKWARD: return Dir.BACKWARD
		Dir.RIGHT: return Dir.RIGHT
		Dir.RIGHT_F: return Dir.RIGHT
		Dir.RIGHT_B: return Dir.RIGHT
		Dir.LEFT: return Dir.LEFT
		Dir.LEFT_F: return Dir.LEFT
		Dir.LEFT_B: return Dir.LEFT
		_: return Dir.NEUTRAL # unreachable


static func from_vector(vector: Vector2) -> Dir:
	var r := -1
	match vector:
		Vector2.ZERO: r = Dir.NEUTRAL
		Vector2(0, -1): r = Dir.FORWARD
		Vector2(0, 1): r = Dir.BACKWARD
		Vector2(1, 0): r = Dir.RIGHT
		Vector2(-1, 0): r = Dir.LEFT
		Vector2(1, -1): r = Dir.RIGHT_F
		Vector2(1, 1): r = Dir.RIGHT_B
		Vector2(-1, -1): r = Dir.LEFT_F
		Vector2(-1, 1): r = Dir.LEFT_B
	assert(r != -1, 'Vector does not correspond to any Direction.Dir ' + str(vector))
	return r as Dir


static func to_vector(dir: Dir) -> Vector2:
	match dir:
		Dir.NEUTRAL: return Vector2.ZERO
		Dir.FORWARD: return Vector2(0, -1)
		Dir.BACKWARD: return Vector2(0, 1)
		Dir.RIGHT: return Vector2(1, 0)
		Dir.RIGHT_F: return Vector2(1, -1)
		Dir.RIGHT_B: return Vector2(1, 1)
		Dir.LEFT: return Vector2(-1, 0)
		Dir.LEFT_F: return Vector2(-1, -1)
		Dir.LEFT_B: return Vector2(-1, 1)
		_: return Vector2.ZERO # unreachable


static func get_right_group() -> Array[Dir]:
	return [Dir.RIGHT, Dir.RIGHT_F, Dir.RIGHT_B]


static func get_left_group() -> Array[Dir]:
	return [Dir.LEFT, Dir.LEFT_F, Dir.LEFT_B]


static func get_forward_group() -> Array[Dir]:
	return [Dir.FORWARD, Dir.LEFT_F, Dir.RIGHT_F]


static func get_backward_group() -> Array[Dir]:
	return [Dir.BACKWARD, Dir.LEFT_B, Dir.RIGHT_B]


static func get_simplified(include_neutral: bool = false) -> Array[Dir]:
	var _r = [Dir.FORWARD, Dir.BACKWARD, Dir.LEFT, Dir.RIGHT]
	if include_neutral:
		_r.append(Dir.NEUTRAL)
	return _r

static func get_diagonal() -> Array[Dir]:
	return [Dir.LEFT_F, Dir.RIGHT_F, Dir.LEFT_B, Dir.RIGHT_B]


static func get_all_moving(include_neutral: bool = false) -> Array[Dir]:
	var _r = [
		Dir.FORWARD,
		Dir.BACKWARD,
		Dir.RIGHT,
		Dir.RIGHT_F,
		Dir.RIGHT_B,
		Dir.LEFT,
		Dir.LEFT_F,
		Dir.LEFT_B
	]
	if include_neutral:
		_r.append(Dir.NEUTRAL)
	return _r
