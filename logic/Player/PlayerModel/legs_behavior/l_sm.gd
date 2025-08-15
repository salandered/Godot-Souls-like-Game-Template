extends Node
class_name LegsSM

@export var behaviors_cont: LegsBehaviorsContainer
@export var actions_cont: LegsActionsContainer

@onready var current_behavior: LegsBehavior = $LegsBehavior/JogLegs
@onready var current_action: LegsAction = $LegsActions/Idle

enum MotionType {IDLE, START, CYCLE, STOP}
var current_motion_type: MotionType = MotionType.IDLE


func switch_to(next_legs_behavior: LegsBehavior, input: InputPackage):
	if next_legs_behavior != current_behavior or next_legs_behavior.behavior_name == "double_legs":
		current_behavior.on_exit_behavior()
		current_behavior = next_legs_behavior
		#current_behavior.torso_behavior = torso.current_behavior
		current_behavior.on_enter_behavior(input)


func forward_export_fields():
	actions_cont.player = player
	actions_cont.camera = camera
	actions_cont.combat = combat
	actions_cont.legs_sm = self
	actions_cont.legs_anim_settings = legs_anim_settings
	actions_cont.forward_export_fields()

	behaviors_cont.legs_sm = self
