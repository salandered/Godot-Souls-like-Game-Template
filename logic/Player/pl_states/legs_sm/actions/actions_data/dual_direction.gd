extends RefCounted
class_name DualDirection

enum Dir {PRIMARY, SECONDARY}

# Initial configuration
var speed_primary: float
var speed_secondary: float
var anim_primary: String
var anim_secondary: String

# Current state
var curr_direction: Dir
var default_speed: float
var anim_id: String


func _init(primary_speed: float, secondary_speed: float, primary_anim: String, secondary_anim: String) -> void:
	speed_primary = primary_speed
	speed_secondary = secondary_speed
	anim_primary = primary_anim
	anim_secondary = secondary_anim


func set_direction(dir: Dir):
	curr_direction = dir
	match dir:
		Dir.PRIMARY:
			default_speed = speed_primary
			anim_id = anim_primary
		Dir.SECONDARY:
			default_speed = speed_secondary
			anim_id = anim_secondary


func get_dir_int() -> int:
	return 1 if curr_direction == Dir.PRIMARY else -1


func get_anims() -> Array[String]:
	return [anim_primary, anim_secondary]