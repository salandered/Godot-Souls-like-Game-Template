extends RefCounted
class_name StrafeDir


enum E {
	FORWARD,
	BACKWARD,
	RIGHT,
	RIGHT_F,
	RIGHT_B,
	LEFT,
	LEFT_F,
	LEFT_B
}

static func name_(dir: E) -> String:
	return E.find_key(dir)


static func simplify(dir: E) -> E:
	match dir:
		E.FORWARD: return E.FORWARD
		E.BACKWARD: return E.BACKWARD
		E.RIGHT: return E.RIGHT
		E.RIGHT_F: return E.RIGHT
		E.RIGHT_B: return E.RIGHT
		E.LEFT: return E.LEFT
		E.LEFT_F: return E.LEFT
		E.LEFT_B: return E.LEFT
		_: return dir # unreachable


static func from_vector(vector: Vector2) -> E:
	var r = -1
	match vector:
		Vector2(0, -1): r = E.FORWARD
		Vector2(0, 1): r = E.BACKWARD
		Vector2(1, 0): r = E.RIGHT
		Vector2(-1, 0): r = E.LEFT
		Vector2(1, -1): r = E.RIGHT_F
		Vector2(1, 1): r = E.RIGHT_B
		Vector2(-1, -1): r = E.LEFT_F
		Vector2(-1, 1): r = E.LEFT_B
	assert(r != -1, 'Vector does not correspond to any StrafeDir.E ' + str(vector))
	return r as E

static func to_vector(dir: E) -> Vector2:
	match dir:
		E.FORWARD: return Vector2(0, -1)
		E.BACKWARD: return Vector2(0, 1)
		E.RIGHT: return Vector2(1, 0)
		E.RIGHT_F: return Vector2(1, -1)
		E.RIGHT_B: return Vector2(1, 1)
		E.LEFT: return Vector2(-1, 0)
		E.LEFT_F: return Vector2(-1, -1)
		E.LEFT_B: return Vector2(-1, 1)
		_: return Vector2.ZERO # unreachable