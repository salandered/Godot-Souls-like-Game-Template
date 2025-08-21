extends Combo_


func is_triggered(input: InputPackage) -> bool:
	print_.prefix("Combo 🗡️ " + name, "Checking for trigger for state " + state.state_name + \
			" triggered_state: " + state_to_trigger + \
			" current input.actions: " + str(input.actions)
			)
	print_.prefix("Combo 🗡️ ", "Checks only PS.longsword_1 for now")
	# if input.actions.has( current weapon light attack state code ) in future for scalability
	if input.actions.has(PS.longsword_1) and have_target_for_ripost():
		print_.prefix("Combo 🗡️ " + name, "triggered")
		return true
	return false


# extremely lazy implementation, for nicer results, use conuses or other 
# "area of ripost grabbing", also the target defined by this algo
# needs to be notified it is being ripost-grabbed, probably via some State.react_on_ripost(). 
# But the workflow is correct, nothing conceptual will change, just better animations etc. 
func have_target_for_ripost() -> bool:
	var parried_victims = get_tree().get_nodes_in_group("parried_humanoid")
	print_.prefix("Combo 🗡️ ", "ripost(): victims in group: " + str(parried_victims.size()))
	for player in parried_victims:
		var dist = player.global_position.distance_to(state.player.global_position)
		print_.prefix("Combo 🗡️", "candidate: " + str(player.name) + " dist: " + str(dist))
		if dist < 2.0:
			print_.prefix("Combo 🗡️", "ripost target acquired")
			return true
	print_.prefix("Combo 🗡️ ", "ripost: no target in range")
	return false
