## based on: Script for playing Gobot's animations and controlling its 3D model.
## see gobot_skin_3d for a reference (M4)
# Gobot means out girl or any other character maybe.
class_name GobotSkin3D extends Node3D

## Emitted when Gobot's feet hit the ground will running.
## 20 Emitted in animations like running when the character's feet hit the ground.
signal stepped

## 10 Gobot's MeshInstance3D model.
#@export var gobot_mesh: MeshInstance3D = null

@export var main_animation_player : AnimationPlayer

var moving_blend_path := "parameters/StateMachine/move/blend_position"

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

## 10 Sets the model to a neutral, action-free state.
#func idle():
	#_state_machine.travel("Idle")
## Sets the model to a running/walking animation or forward movement.
#func walk():
	#_state_machine.travel("Walk")
	#
	#
#
#func pray():
	#_state_machine.travel("Pray")


func _ready():
	animation_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1

func set_moving(value : bool):
	moving = value
	if moving:
		state_machine.travel("move")
	else:
		state_machine.travel("idle")

func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)

func jump():
	state_machine.travel("jump")

func fall():
	state_machine.travel("fall")
#
#func punch():
	#animation_tree["parameters/PunchOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _step() -> void:
	stepped.emit()
