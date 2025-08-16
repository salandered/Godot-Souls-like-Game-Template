extends Node
class_name PlayerSM

@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var legs_sm: LegsSM

# Fixed animator setup (we stick to SimpleAnimator_ now)
@export var torso_animator: SimpleAnimator_ # the Torso skeleton modifier
@export var animations_source: AnimationPlayer # clip library for torso actions (if actions read from here)
# @export var torso_anim_settings: AnimationPlayer # settings player if you ever need to fade torso influence
@export var animation_settings: AnimationPlayer # settings player if you ever need to fade torso influence


var current_state: PlayerState
var current_action: PlayerAction

@onready var container: PlayerStatesContainer = %StatesContainer

func initialise():
	var empty_input := InputPackage.new()

	current_state = container.state_by_name(PS.run)
	current_action = container.action_by_name(PS.action_run)

	# todo: better
	legs_sm.current_behavior = container.legs_behavior_by_name("leg_run_behavior")
	legs_sm.current_action = container.legs_action_by_name(legs_sm.current_behavior.used_actions[0])
	legs_sm.current_behavior.on_enter_behavior(empty_input)

	current_state._on_enter_state(empty_input)

	animation_settings.play(A.SET_torso_legs, 0.2)


func update(input: InputPackage, delta: float) -> void:
	input = combat.contextualize(input)
	input = area_awareness.contextualize(input)
	area_awareness.last_input_package = input

	var verdict := current_state.check_relevance(input)
	if verdict != "okay":
		print_.prefix("=T SM=", current_state.state_name + " -> " + verdict)
		# swap to the named state (lookup below)
		current_state._on_exit_state()
		current_state = container.state_by_name(verdict)
		current_state._on_enter_state(input)

	current_state._update(input, delta)


# used to be in player model
# func update(input: InputPackage, delta: float):
# 	if fly_mode_enabled:
# 		_handle_fly_mode(input, delta)
# 		return

# 	input = combat.contextualize(input)
# 	input = area_awareness.contextualize(input)
# 	area_awareness.last_input_package = input
# 	var verdict = current_state.check_transition(input)
# 	if verdict != "okay": # todo not okay
# 		switch_to(verdict)

# 	# TODO TODO: moved back here, TorsoStates triggers _update from legs_animator behavior -> doubledipping
# 	current_state.update_resources(delta)
	
# 	current_state._update(input, delta)


# func switch_to(state: String):
# 	print_.prefix("=PSM=", current_state.state_name + " -> " + state)
# 	current_state._on_exit_state()
# 	current_state = states_container.states[state]
# 	current_state._on_enter_state()
