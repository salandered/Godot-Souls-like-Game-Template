## based on: Script for playing Gobot's animations and controlling its 3D model.
## see gobot_skin_3d for a reference (M4)
# Gobot means our girl or any other character maybe.
class_name PlayerSkin extends Node3D

## Emitted when Gobot's feet hit the ground will running.
## 20 Emitted in animations like running when the character's feet hit the ground.
signal stepped

var weapon_active := false

## 10 Gobot's MeshInstance3D model.
#@export var gobot_mesh: MeshInstance3D = null
@onready var iamellipse: CharacterBody3D = $'../..'

@export var main_animation_player : AnimationPlayer

# TODO: why it is not MoveSM?
var moving_blend_path := "parameters/StateMachine/move/blend_position"

# False : set animation to "idle"
# True : set animation to "move"
# @onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var extra_anim = $AnimationTree.get_tree_root().get_node("Extra")
@onready var anim_move_sm : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/MoveSM/playback")
@onready var anim_attack_sm : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/AttackSM/playback")
@onready var first_attack_hold: Timer = $FirstAttackHold

var first_attack_toggle := false
var second_attack_toggle := false
var is_anim_attacking := false



func set_is_anim_attacking_(value:bool):
	is_anim_attacking = value
	
func _ready():
	anim_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1

func idle():
	print('==== idle!')
	print(anim_move_sm)
	anim_move_sm.travel("idle")

func set_moving():
	anim_move_sm.travel("move")
	
func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	anim_tree.set(moving_blend_path, move_speed)
	
func jump():
	anim_move_sm.travel("jump")

func fall():
	anim_move_sm.travel("fall")

var FIRST := false

enum WeaponType {
	UNARMED,
	SWORD,
	WAND,
	#BOW # TODO: waiting for ivan
}

var weapon_type_to_node_name := {
	WeaponType.SWORD: 'military_hatchet',
	WeaponType.WAND: 'wand'
}


var path_to_weapon_node := "Armature/Skeleton3D/RighthandSlot/"
var current_weapon := WeaponType.SWORD

func _hide_current_weapon():
	if current_weapon != WeaponType.UNARMED:
		get_node(path_to_weapon_node + weapon_type_to_node_name[current_weapon]).hide()

func _show_weapon(weapon_type: WeaponType):
	if weapon_type != WeaponType.UNARMED:
		get_node(path_to_weapon_node + weapon_type_to_node_name[weapon_type]).show()

func handle_action(is_idle: bool):
	if Input.is_action_just_pressed("action"):
		print("  ")
		match current_weapon:
			WeaponType.SWORD:
				attack_with_sword(is_idle)
			WeaponType.WAND:
				attack_with_wand(is_idle)
				iamellipse.stop_movement(0.3, 0.8)

	if Input.is_action_just_pressed("ui_accept"):
		hit()
				
	# TODO: is_anim_attacking is unreliable in case animation was interrupted
	# TODO: animations to equip/hide
	if not is_anim_attacking:
		if Input.is_action_just_pressed("slot_1"):
			_hide_current_weapon()
			current_weapon = WeaponType.SWORD
			print("switched to current_weapon", current_weapon)
			_show_weapon(current_weapon)
		elif Input.is_action_just_pressed("slot_3"):
			_hide_current_weapon()
			current_weapon = WeaponType.WAND
			print("switched to current_weapon", current_weapon)
			_show_weapon(current_weapon)
		elif Input.is_action_just_pressed("hide_weapon"):
			_hide_current_weapon()
			current_weapon = WeaponType.UNARMED
			print("switched to current_weapon", current_weapon)
			

func attack_with_sword(is_idle: bool):
	#region: some debug
	#move_speed = clamp(weighted_speed, 0.0, 1.0)
	#if not is_moving:
		#animation_tree.set("parameters/AttackRunAdd/add_amount", 0)
	#var i := 0
	#if i % 3 ==0:
		#print(move_speed)
		#print(1 - move_speed)
	#i+=1
	
	# print("AAA >>>>>>>>>>>")
	#var a := animation_tree.tree_root
	
	# var a = animation_tree.tree_root.get_node("AnimationBlendAttackLegs")
	# print(a)
	# print(typeof(a))
	#animation_tree.set("parameters/Blend2/blend_amount", 1 - move_speed)
	#else:
		#animation_tree.set("parameters/AttackRunAdd/add_amount", 1)
	#endregion
	#print("== attacking?", attacking, "      idle?", idle)
	
	var first_attack_name := 'SliceRightL'
	var second_attack_name := 'SliceLeftR'
	
	print("timer", first_attack_hold.time_left)
	print(first_attack_toggle, " ", second_attack_toggle)
	# no attack_with_sword at all
	var is_os_active: bool = anim_tree.get("parameters/IdleAttack1Shot/active")
	print("is active ", is_os_active)
	#if not first_attack_toggle and not second_attack_toggle:
	print("FIIIIRST", FIRST)
	if not FIRST:
		FIRST = true
		if is_idle:
			print("travel to 1st at ", first_attack_name)
			anim_attack_sm.travel(first_attack_name)
			if not is_os_active:
				anim_tree["parameters/IdleAttack1Shot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			anim_tree["parameters/MoveAttack1Shot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	# first attack_with_sword ending
	#elif first_attack_toggle and not first_attack_hold.time_left and not second_attack_toggle:
	else:
		FIRST = false
		# last check just to be sure
		if is_idle:
			print("First a t to CUSTOM ", false)
			first_attack_toggle = false # TODO: ugly
			print("travel to 2nd at ", second_attack_name)
			anim_attack_sm.travel(second_attack_name)
			#anim_tree["parameters/IdleAttack1Shot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			# and one shot is triggered already
		else: 
			# no logic for moving and second attack_with_sword so far
			pass
	# second attack_with_sword hold
	#elif second_attack_toggle:
		#pass
		
	#print("  ")

func attack_with_wand(is_idle: bool):
	# if not attacking
	extra_anim.animation = 'new_stuff/torch_kinda'
	anim_tree["parameters/Extra1S/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	pass

func hit():
	print("got HIT")
	extra_anim.animation = 'LightSword/death'
	anim_tree["parameters/Extra1S/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	iamellipse.stop_movement(0.2, 0.2)




func first_attack_toggle__(value: bool):
	# called by attack_with_sword animation
	print("First a t to ", value)
	first_attack_toggle = value

func second_attack_toggle__(value: bool):
	print("Second a t to ", value)
	second_attack_toggle = value
	
func _step() -> void:
	stepped.emit()
