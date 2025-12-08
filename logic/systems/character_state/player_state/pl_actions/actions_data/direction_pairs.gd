extends RefCounted
class_name DirPairs


enum ChangeType {
	OPPOSITE,
	SLIGHT,
	SLIGHTEST,
	SAME
}

static var all_dir_pairs: Dictionary = {
	# 180 OPPOSITE (most frequent)
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.BACKWARD): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.RIGHT, Direction.Dir.LEFT): ChangeType.OPPOSITE,
	
	# 90 VERT STRAFE SPAM (frequent) (e.g W pressed A/D spams)
	Vector2i(Direction.Dir.RIGHT_F, Direction.Dir.LEFT_F): ChangeType.SLIGHT,
	Vector2i(Direction.Dir.RIGHT_B, Direction.Dir.LEFT_B): ChangeType.SLIGHT,

	# other 90
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.RIGHT): ChangeType.SLIGHT,
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.LEFT): ChangeType.SLIGHT,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.RIGHT): ChangeType.SLIGHT,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.LEFT): ChangeType.SLIGHT,
	
	# other 90 (diagonal neighbors)
	Vector2i(Direction.Dir.LEFT_F, Direction.Dir.LEFT_B): ChangeType.SLIGHT,
	Vector2i(Direction.Dir.RIGHT_F, Direction.Dir.RIGHT_B): ChangeType.SLIGHT,

	# 45 SLIGHTEST
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.RIGHT_F): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.LEFT_F): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.RIGHT_B): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.LEFT_B): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.RIGHT, Direction.Dir.RIGHT_F): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.RIGHT, Direction.Dir.RIGHT_B): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.LEFT, Direction.Dir.LEFT_F): ChangeType.SLIGHTEST,
	Vector2i(Direction.Dir.LEFT, Direction.Dir.LEFT_B): ChangeType.SLIGHTEST,

	# 135
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.RIGHT_B): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.FORWARD, Direction.Dir.LEFT_B): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.RIGHT_F): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.BACKWARD, Direction.Dir.LEFT_F): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.RIGHT, Direction.Dir.LEFT_F): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.RIGHT, Direction.Dir.LEFT_B): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.LEFT, Direction.Dir.RIGHT_F): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.LEFT, Direction.Dir.RIGHT_B): ChangeType.OPPOSITE,
	
	# 180 OPPOSITE (least frequent)
	Vector2i(Direction.Dir.RIGHT_F, Direction.Dir.LEFT_B): ChangeType.OPPOSITE,
	Vector2i(Direction.Dir.RIGHT_B, Direction.Dir.LEFT_F): ChangeType.OPPOSITE,
}


## -1 if not found
static func get_change_type(from_dir: int, to_dir: int) -> ChangeType:
	var key = Vector2i(from_dir, to_dir)
	return all_dir_pairs.get(key, -1)
