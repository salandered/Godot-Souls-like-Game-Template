extends RefCounted
class_name Direction


enum Dir {
	NEUTRAL,
	FORWARD,
	BACKWARD,
	RIGHT,
	RIGHT_F,
	RIGHT_B,
	LEFT,
	LEFT_F,
	LEFT_B
}

static func name_(dir: Dir) -> String:
	return Dir.find_key(dir)


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