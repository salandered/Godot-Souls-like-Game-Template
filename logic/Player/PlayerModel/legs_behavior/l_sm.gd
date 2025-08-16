extends Node
class_name LegsSM

#@export var behaviors_cont: LegsBehaviorsContainer
@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM
@export var area_awareness: AreaAwareness

# @export var camera: FancyCamera
@export var combat: HumanoidCombat
# @export var legs_anim_settings: AnimationPlayer

enum MotionType {IDLE, START, CYCLE, STOP}
var current_motion_type: MotionType = MotionType.IDLE

var current_behavior: LegsBehavior
var current_action: LegsAction


# func _ready() -> void:


func update(input: InputPackage, delta: float) -> void:
	current_behavior.update(input, delta)


func switch_to(next_legs_behavior: LegsBehavior, input: InputPackage):
	if next_legs_behavior == current_behavior and next_legs_behavior.behavior_name != "double_legs":
		return
	print_.prefix("=LSM=", "switching legs behavior from " + current_behavior.behavior_name + " to " + next_legs_behavior.behavior_name)
	current_behavior.on_exit_behavior()
	current_behavior = next_legs_behavior
	current_behavior.player_state = player_sm.current_behavior
	current_behavior.on_enter_behavior(input)
