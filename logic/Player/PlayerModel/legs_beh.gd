# extends Node
# ## Legs SM consists of states called legs_behaviours. 
# ## legs_behaviour is just a piece of transition logic, all it does is it 
# ## manages on what action updates our legs currently and nothing more
# class_name LegsBehaviour2
extends Node
# # @export var behaviour_name : String

# # var combat : KajCombat
# # var player : KajinPlayer
# # var camera : PlayerCamera
# # var legs : Legs
# # var legs_anim_settings : AnimationPlayer
# # var area_awareness : KajAreaAwareness
# # var torso_behaviour : TorsoBehaviour

# # var actions : LegsActionsContainer

# # func update(_input : InputPackage, _delta : float):
# # 	pass

# # func switch_to(next_action_name : String, input : InputPackage):
# # 	var previous_action = legs.current_action
# # 	legs.current_action.on_exit_action()
# # 	legs.current_action = actions.get_by_name(next_action_name)
# # 	legs.current_action.setup_animator(previous_action, input)
# # 	legs.current_action.on_enter_action(input)

# # func on_enter_behaviour(_input : InputPackage):
# # 	pass

# # func on_exit_behaviour():
# # 	pass
