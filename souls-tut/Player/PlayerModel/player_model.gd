extends Node
class_name PlayerModel

# todo consider: not a fan of sharing logic between enemy/player
@export var is_enemy: bool = false


@onready var player = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SkeletonAnimator
@onready var combat = $Combat as HumanoidCombat
@onready var resources = $Resources as HumanoidResources

@onready var active_weapon: WeaponOh = $RightWrist/WeaponSocket/SwordOh as SwordOh
# @onready var weapons = {
# 	"sword" = $....Sword,
# 	"bow" = $....Bow,
# 	"greatsword" = $....Greatsword,
# 	....
# }

var current_state: BasePlayerState

@onready var states = {
	# move
	PlayerState.idle: $States/Idle,
	PlayerState.run: $States/Run,
	PlayerState.sprint: $States/Sprint,
	PlayerState.jump_run: $States/JumpRun,
	PlayerState.midair: $States/Midair,
	PlayerState.landing_run: $States/LandingRun,
	PlayerState.jump_sprint: $States/JumpSprint,
	PlayerState.landing_sprint: $States/LandingSprint,
	# combat
	PlayerState.slash_1: $States/Slash1,
	PlayerState.slash_2: $States/Slash2,
	PlayerState.slash_3: $States/Slash3,
	PlayerState.staggered: $States/Staggered,
	PlayerState.parry: $States/Parry,
	PlayerState.parried: $States/Parried,
	PlayerState.riposte: $States/Riposte,
	PlayerState.death: $States/Death,
}


func _ready():
	assert(len(states) == 16) # some stability
	current_state = states[PlayerState.idle]
	for state: BasePlayerState in states.values():
		state.player = player
		state.resources = resources
		state.states_data_repo = $StatesData
		state.assign_combos()


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
	# print(" = Playerstateswitching = ")
	# print("", current_state, ' ->')
	current_state.on_exit_state()
	current_state = states[state]
	# print("", current_state)
	current_state.on_enter_state()
	current_state.mark_enter_state()
	resources.pay_resource_cost(current_state)
	animator.play(current_state.animation)
