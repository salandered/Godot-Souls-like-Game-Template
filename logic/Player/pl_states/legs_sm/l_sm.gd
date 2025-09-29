@tool
@icon("res://-assets-/x_misc/x_icons/node-colors/orange-2.png")

extends Node
class_name LegsSM

@export var container: PlayerStatesContainer
@export var player_sm: PlayerSM
@export var area_awareness: AreaAwareness

@export var combat: HumanoidCombat

enum MotionType {IDLE, START, CYCLE, STOP}

@export var full_body_animator: ModifierAnimator
@export var legs_animator: ModifierAnimator


var current_behavior: LegsBehavior
# It should belong here! current_action is managed by the "pool" of actions. 
# Behavior changes may or may NOT change current action.
var current_action: LegsAction


func update(input: InputPackage, delta: float) -> void:
	current_behavior.update(input, delta)


func switch_to(next_behavior: LegsBehavior, input: InputPackage):
	if next_behavior == current_behavior:
		print_.lsm_beh("", "not switching legs (same behavior) " + current_behavior.behavior_name, 2)
		return
	print_.lsm_beh("↪️", pp.ts(current_behavior.behavior_name, "=>", next_behavior.behavior_name), 2)
	current_behavior._on_exit_behavior()
	current_behavior = next_behavior
	current_behavior._on_enter_behavior(input)
