# extends Node
# ## Torso machine consists of states called torso_behaviours
# class_name TorsoBehaviour

# # TODO clean up regions and put update into update and transition into transition
# # TODO form transition bricks docs
# # TODO create templates ffs

# ## torso states just have a fixed legs_behaviour attached to them. 
# ## It is simply wired in the editor via an export field. 
# @export var legs_behaviour : LegsBehaviour
# @export var behaviour_name : String

# @export_group("transition logic")
# @export var priority : int = 0
# @export var behaviour_map = {
# 	"engaged" : "combat_walk",
# 	"move_fast" : "sprint",
# 	"attack_tap" : "SNS_Light_1",
# 	"attack_hold" : "SNS_charged_attack",
# 	"defence_tap" : "SNS_shield_bash",
# 	"defence_hold" : "SNS_block",
# 	"jog_consumable" : "jog_consumable",
# 	"slowing_cast" : "slowing_consumable",
# }

# @export var combos : Array[Combo]
# var has_queued_move : bool = false
# var queued_move : String
# var has_forced_move : bool = false
# var forced_move : String

# var animations_source : AnimationPlayer
# var torso_anim_settings : AnimationPlayer
# var simple_torso : AnimatorModifier
# var locomotion_torso : Locomotion



# var combat : KajCombat
# var player : KajinPlayer
# var camera : PlayerCamera
# var legs : Legs
# var backend : MovesBackend
# var torso : KajStatesContainer
# var area_awareness : KajAreaAwareness

# var enter_move_time : float

# var actions : Dictionary
# var current_action : TorsoAction

# func check_relevance(input : InputPackage) -> String:
# 	if has_queued_move and transitions_to_queued():
# 		try_force_move(queued_move)
# 		has_queued_move = false

# 	if has_forced_move:
# 		has_forced_move = false
# 		return forced_move

# 	return transition_logic(input)

# func transition_logic(_input : InputPackage) -> String:
# 	return "okay"


# func map_with_dictionary(input : InputPackage, map : Dictionary):
# 	for action in input.input_actions:
# 		if map.keys().has(action):
# 			input.behaviour_names.append(map[action])
# 	return input

# func map_with_combos(input) -> InputPackage:
# 	for combo in combos:
# 		combo.map(input)
# 	return input

# func switch_action_to(next_action : String, input : InputPackage):
# 	if current_action:
# 		current_action.on_exit_action()
# 	current_action = actions[next_action]
# 	current_action.setup_animator(input)
# 	current_action._on_enter_action(input)

# func try_queue_move(new_queued_move : String):
# 	if not has_queued_move:
# 		queued_move = new_queued_move
# 		has_queued_move = true
# 	elif torso.behaviours[new_queued_move].priority > torso.behaviours[queued_move].priority:
# 		queued_move = new_queued_move

# func try_force_move(new_forced_move : String):
# 	if not has_forced_move:
# 		has_forced_move = true
# 		forced_move = new_forced_move
# 	elif torso.behaviours[new_forced_move].priority >= torso.behaviours[forced_move].priority:
# 		forced_move = new_forced_move


# func _update(input : InputPackage, delta : float):
# 	legs.current_behaviour.update(input, delta)
# 	update(input, delta)

# func update(_input : InputPackage, _delta : float):
# 	pass
extends Node
# ## - And then we call the real `on_enter_state` method that is empty in the base and requires overriding in heirs.
# func _on_enter_behaviour(input : InputPackage):
# 	choose_initial_behavior(input)
# 	## - single legs beh attached to torso state => and all we need to do is to forcibly call the legs SM to switch into this defined state.
# 	legs_behaviour.torso_behaviour = self
# 	legs.switch_to(legs_behaviour, input)
# 	on_enter_behaviour(input)

# func choose_initial_behavior(input: InputPackage):
# 	pass

# func on_enter_behaviour(_input : InputPackage):
# 	pass

# func _on_exit_behaviour():
# 	current_action = null
# 	on_exit_behaviour()
	
# func on_exit_behaviour():
# 	pass
