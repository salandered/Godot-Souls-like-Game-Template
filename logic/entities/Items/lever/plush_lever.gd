@tool
@icon("res://-assets-/x_icons/lever/icon_lever_blue.png")
class_name GenericLever
extends BaseLever


func _on_switch_inside_anim_implementation():
	PlayerStats.increase_count_plush_launches()
