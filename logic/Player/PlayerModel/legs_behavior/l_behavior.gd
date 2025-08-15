extends Node
## Legs SM consists of states called LegsBehavior. 
## LegsBehavior is just a piece of transition logic, all it does is it 
## manages on what action updates our legs currently
class_name LegsBehavior


@export var behavior_name: String

#var combat : KajCombat
var player: Princess
#var camera : PlayerCamera
var legs_sm : LegsSM
var legs_anim_settings: AnimationPlayer
var area_awareness: AreaAwareness
#var torso_behavior : TorsoBehavior

var actions : LegsActionsContainer

func update(_input: InputPackage, _delta: float):
	pass

func switch_to(next_action_name: String, input: InputPackage):
	var previous_action = legs_sm.current_action
	legs_sm.current_action.on_exit_action()
	legs_sm.current_action = actions.get_by_name(next_action_name)
	legs_sm.current_action.setup_animator(previous_action, input)
	legs_sm.current_action.on_enter_action(input)

func on_enter_behavior(_input: InputPackage):
	pass

func on_exit_behavior():
	pass
