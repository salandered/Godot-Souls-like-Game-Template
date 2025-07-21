extends Node
class_name PlayerModel

@onready var player = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SkeletonAnimator
@onready var combat = $Combat as HumanoidCombat

@onready var active_weapon: Weapon = $RightWrist/WeaponSocket/Sword as Sword
#@onready var weapons = {
	#"sword" = $....Sword,
	#"bow" = $....Bow,
	#"greatsword" = $....Greatsword,
	#....
#}

var current_state: BasePlayerState

@onready var states = {
	PlayerState.idle: $States/IdleState,
	PlayerState.run: $States/RunState,
	PlayerState.sprint: $States/SprintState,
	PlayerState.jump_run: $States/JumpRunState,
	PlayerState.midair: $States/MidairState,
	PlayerState.landing_run: $States/LandingRunState,
	PlayerState.jump_sprint: $States/JumpSprintState,
	PlayerState.landing_sprint: $States/LandingSprintState,
	PlayerState.slash_1: $States/Slash1State,
	PlayerState.slash_2: $States/Slash2State,
	PlayerState.slash_3: $States/Slash3State
}


func _ready():
	current_state = states[PlayerState.idle]
	for state in states.values():
		state.player = player


func update(input: InputPackage, delta: float):
	input = combat.translate_combat_actions(input)
	var relevance = current_state.check_relevance(input)
	# todo not okey
	if relevance != "okay":
		switch_to(relevance)
	#print(current_state.animation)
	current_state.update(input, delta)


func switch_to(state: String):
	print("= Player state switching = ")
	print("   ", current_state, ' ->')
	current_state.on_exit_state()
	current_state = states[state]
	print("   ", current_state)
	current_state.on_enter_state()
	current_state.mark_enter_state()
	animator.play(current_state.animation)


# func _ready():
# 	current_state = states["idle"]
# 	for state in states.values():
# 		state.player = player


# func update(input_data: InputData, delta: float):
# 	# called from player's physical process
# 	var new_state_name = current_state.check_relevance(input_data)
# 	if states[new_state_name] != current_state:
# 		switch_to(new_state_name)
# 	current_state.update(input_data, delta)
