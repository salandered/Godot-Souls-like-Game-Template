extends Node3D


func _on_front_hide_lever_sig_lever_switched() -> void:
	visible = not visible
