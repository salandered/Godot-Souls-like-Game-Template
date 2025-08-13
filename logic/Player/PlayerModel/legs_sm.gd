extends Node
# @export var behaviours : LegsBehavioursContainer
# @export var actions : LegsActionsContainer

# @onready var current_behaviour : LegsBehaviour = $LegsBehaviours/JogLegs
# @onready var current_action : LegsAction = $LegsActions/Idle

# enum MotionType { IDLE, START, CYCLE, STOP }
# var current_motion_type : MotionType = MotionType.IDLE


# func switch_to(next_legs_behaviour : LegsBehaviour, input : InputPackage):
# 	if next_legs_behaviour != current_behaviour or next_legs_behaviour.behaviour_name == "double_legs":
# 		current_behaviour.on_exit_behaviour()
# 		current_behaviour = next_legs_behaviour
# 		current_behaviour.torso_behaviour = torso.current_behaviour
# 		current_behaviour.on_enter_behaviour(input)


# func forward_export_fields():
# 	actions.player = player
# 	actions.camera = camera
# 	actions.combat = combat
# 	actions.legs = self
# 	actions.legs_anim_settings = legs_anim_settings
# 	actions.forward_export_fields()
	
# 	behaviours.legs = self
