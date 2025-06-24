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
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MoveStateMachine/playback")

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


var that_AT_parameter := ""
var attacking := false

func _ready():
	animation_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1

func set_moving(value : bool):
	moving = value
	if moving:
		state_machine.travel("move")
		animation_tree.set("that_AT_parameter", move_speed)
	else:
		state_machine.travel("idle")
		animation_tree.set("that_AT_parameter", 0)
		
	

func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)
	
	animation_tree.set("that_AT_parameter", move_speed)

func jump():
	state_machine.travel("jump")

func fall():
	state_machine.travel("fall")
#
func attack(is_falling:bool, is_moving:bool, weighted_speed):
	#move_speed = clamp(weighted_speed, 0.0, 1.0)
	#if not is_moving:
		#animation_tree.set("parameters/AttackRunAdd/add_amount", 0)
	#var i := 0
	#if i % 3 ==0:
		#print(move_speed)
		#print(1 - move_speed)
	#i+=1
	
	print("AAA >>>>>>>>>>>")
	#var a := animation_tree.tree_root
	
	var a = animation_tree.tree_root.get_node("AnimationBlendAttackLegs")
	print(a)
	print(typeof(a))
	
	#animation_tree.set("parameters/Blend2/blend_amount", 1 - move_speed)
	#else:
		#animation_tree.set("parameters/AttackRunAdd/add_amount", 1)
	if not attacking:
		#animation_tree.set("parameters/AttackRunAdd/add_amount", move_speed)
		animation_tree["parameters/AttackOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	
func attack_toggle(value: bool):
	attacking = value
	
	
func _step() -> void:
	stepped.emit()
