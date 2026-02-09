class_name DevHitTarget
extends SimpleTarget

@onready var text_marker: Marker3D = $TextMarker


const FLOAT_SPEED: float = 0.3
const TEXT_DURATION: float = 2.2

# func _on_my_area_hit_imp():
# 	var text := _get_hit_debug_text(last_hit)
# 	var color := _get_damage_color(last_hit.damage)
	
# 	DebugText.spawn(get_tree().current_scene, text_marker.global_position, text, TEXT_DURATION, color, FLOAT_SPEED)


# func _get_hit_debug_text(data: HitData) -> String:
# 	return "Damage: %.1f\nAnim Speed Scale: %.2f\nState: %s" % [
# 		data.damage,
# 		data.anim_global_speed_scale,
# 		data.char_state_name
# 	]


# func _get_damage_color(dmg: float) -> Color:
# 	var t := clampf((dmg - 10.0) / (45.0 - 10.0), 0.0, 1.0)
# 	# from desaturated B to desaturated R
# 	var start = Color(0.5, 0.6, 0.8)
# 	var end = Color(0.8, 0.5, 0.5)
	
# 	return start.lerp(end, t)


##

func __LOG_B() -> bool:
	return true
