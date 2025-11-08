extends RefCounted
class_name AttackDirection


enum Dir {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	STAB, # means forward direction
}


static func name_(dir: Dir) -> String:
	return Dir.find_key(dir)
