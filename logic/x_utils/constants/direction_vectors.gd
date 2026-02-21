extends RefCounted
class_name DV

const FORWARD := &"forward"
const BACK := &"back"
const LEFT := &"left"
const RIGHT := &"right"


static var name_to_vec: Dictionary[StringName, Vector2] = {
	FORWARD: Vector2(0, -1),
	BACK: Vector2(0, 1),
	LEFT: Vector2(-1, 0),
	RIGHT: Vector2(1, 0)
}

static var vec_to_name: Dictionary[Vector2, StringName] = {
	Vector2(0, -1): FORWARD,
	Vector2(0, 1): BACK,
	Vector2(-1, 0): LEFT,
	Vector2(1, 0): RIGHT,
}
