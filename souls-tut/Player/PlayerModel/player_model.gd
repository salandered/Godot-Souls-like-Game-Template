extends Node
class_name PlayerModel

# todo consider: not a fan of sharing logic between enemy/player

@export var is_enemy: bool = false

@export var player: CharacterBody3D
@export var skeleton: Skeleton3D
@export var animator: AnimationPlayer
@export var combat: HumanoidCombat
@export var resources: HumanoidResources

@export var active_weapon: WeaponOh
@export var states_container: HumanoidStates
# @onready var weapons = {
# 	"sword" = $....Sword,
# 	"bow" = $....Bow,
# 	"greatsword" = $....Greatsword,
# 	....
# }

var current_state: BasePlayerState


func _ready():
	states_container.player = player
	states_container.accept_states()
	current_state = states_container.states["idle"]


func update(input: InputPackage, delta: float):
	# print("actions gathered ", input.actions)
	input = combat.contextualize(input)
	# print("actions contextualise ", input.actions)

	var relevance = current_state.check_relevance(input)
	# print("relevance", relevance)
	
	if relevance != "okay": # todo not okay
		switch_to(relevance)

	current_state.update_resources(delta)
	current_state.update(input, delta)
	# print("")


func switch_to(state: String):
	if not is_enemy:
		print(current_state.state_name + " -> " + state)
	current_state.on_exit_state()
	current_state = states_container.states[state]
	current_state.on_enter_state()
	current_state.mark_enter_state()
	resources.pay_resource_cost(current_state)
	animator.play(current_state.animation)
