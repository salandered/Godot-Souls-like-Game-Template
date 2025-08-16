extends Node
## Legs SM consists of states called LegsBehavior. 
## LegsBehavior is just a piece of transition logic, all it does is it 
## manages on what action updates our legs currently
class_name LegsBehavior

var container: PlayerStatesContainer
var legs_sm: LegsSM # set by SM
var player: Princess # optional; set by SM if you want it
var combat: HumanoidCombat # optional; set by SM if you want it
# var legs_anim_settings: AnimationPlayer # optional; set by SM if you want it
var area_awareness: AreaAwareness # FILL ME if you use it
var player_state: PlayerState # set by SM when switching

var behavior_name: String

var used_actions: Array[String] = []

func update(_input: InputPackage, _delta: float):
	pass

func switch_action_to(next_action_name: String, input: InputPackage):
	var previous_action := legs_sm.current_action

	previous_action.on_exit_action() # TODO: _on_exit_action ?

	var next_action: LegsAction = container.legs_action_by_name(next_action_name)
	legs_sm.current_action = next_action

	next_action.animate(previous_action, input)

	next_action._on_enter_action(input)

func on_enter_behavior(_input: InputPackage):
	pass

func on_exit_behavior():
	pass
