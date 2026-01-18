@tool
@icon("res://-assets-/x_icons/level/icon_level_yellow.png")

class_name MiniArena
extends BaseLevel


func basic_tonemap_exposure() -> float:
	return 1.1

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.0


func initialise():
	pass


func _on_clean_up_lever_sig_lever_switched() -> void:
	var rigid_bodies := get_descendants.rigid_bodies(self)
	for body in rigid_bodies:
		if body is DarkCrate:
			PushRigidBodies.push_rigid_body(body, Vector3(0.0, 1.0, 1.0), 20)
		else:
			PushRigidBodies.push_rigid_body(body, Vector3(0.0, 1.0, 1.0), 45)


func _on_blow_up_lever_sig_lever_switched() -> void:
	var static_parents := get_descendants.break_static_parents(self)
	for item in static_parents:
		if item and item is BreakStaticParent:
			item.break_myself()

func __LOG_B() -> bool:
	return true
