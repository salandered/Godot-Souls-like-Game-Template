extends RefCounted
class_name DualDirection

enum Dir {PRIMARY, SECONDARY}

# Initial configuration
var _speed_primary: float
var _speed_secondary: float
var _anim_id_primary: String
var _anim_id_secondary: String

# Current state
var _curr_dir: Dir
var _speed: float
var _anim_id: String


func _init(primary_speed: float, secondary_speed: float, primary_anim_id: String, secondary_anim_id: String) -> void:
	_speed_primary = primary_speed
	_speed_secondary = secondary_speed
	_anim_id_primary = primary_anim_id
	_anim_id_secondary = secondary_anim_id


func set_direction(dir: Dir):
	_curr_dir = dir
	match _curr_dir:
		Dir.PRIMARY:
			_speed = _speed_primary
			_anim_id = _anim_id_primary
		Dir.SECONDARY:
			_speed = _speed_secondary
			_anim_id = _anim_id_secondary


func flip_direction() -> void:
	set_direction(Dir.SECONDARY if _curr_dir == Dir.PRIMARY else Dir.PRIMARY)


func get_curr_dir() -> Dir:
	return _curr_dir


func get_curr_speed() -> float:
	return _speed


func get_curr_dir_int() -> int:
	return 1 if _curr_dir == Dir.PRIMARY else -1


func get_curr_anim_id() -> String:
	return _anim_id


func get_all_anim_ids() -> Array[String]:
	return [_anim_id_primary, _anim_id_secondary]


func _to_string() -> String:
	var dir_str := "PRIMARY" if _curr_dir == Dir.PRIMARY else "SECONDARY"
	return "DualDirection(Dir: %s, Speed: %f, Anim: %s)" % [dir_str, _speed, _anim_id]