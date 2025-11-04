@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_propeller.png")
extends Combo_


func is_triggered(input_: InputPackage, curr_state_name: String, curr_action: BaseAction) -> bool:
	print_.combo(name, pp.s("is_triggered?",
				"triggered_state:", state_to_trigger,
				"current input_.actions:", input_.actions
			))
	print_.combo(name, "Checks only PS.axe_slice_1 for now")
	# if input_.actions.has( current weapon light attack state code ) in future for scalability
	if input_.actions.has(PS.axe_slice_1) and have_target_for_ripost():
		print_.combo(name, "triggered")
		return true
	return false


# extremely lazy implementation, for nicer results, use conuses or other 
# "area of ripost grabbing", also the target defined by this algo
# needs to be notified it is being ripost-grabbed, probably via some State.react_on_ripost(). 
# But the workflow is correct, nothing conceptual will change, just better animations etc. 
func have_target_for_ripost() -> bool: # 🗡️
	var parried_victims := get_tree().get_nodes_in_group(Groups.Player_.parried_humanoid)
	print_.combo(name, "ripost(): victims in group: " + str(parried_victims.size()))
	for npc_ in parried_victims:
		var dist: float = npc_.global_position.distance_to(player.global_position)
		print_.combo(name, pp.s("candidate:", npc_.name, "dist:", dist))
		if dist < 2.0:
			print_.combo("", "ripost target acquired")
			return true
	print_.combo(name, "ripost: no target in range")
	return false
