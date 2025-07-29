extends Node
## all hfsm state of an enemy extend this
class_name HFSM

# The global export fields section. You don't need to set them up for each state,
# do only for the top layer single state that contains the whole state machine.
@export_group("Container Fields")
@export var animator: AnimationPlayer
@export var character: CharacterBody3D
@export var player: CharacterBody3D
@export var states_data_repo: GundyrStatesData
@export var resources: HFSMResources
@export var weapons: Array[WeaponOh]

# These fields must be set for each state indivdually.
# states without animation and backend animation (containers) don't need animation field
@export_group("State Fields")
@export var state_name: String
@export var animation: String
@export var backend_animation: String
var enter_state_time: float

var states: Dictionary # { String : HFSM }
var current_state: HFSM = self

## automatically sets to true if we have HFSM children
##    - being set in _accept_substates
##    - false if state is a leaf
var is_container: bool = false


# region >>> FAIR DOCS <<<
# So, how to use all this?
# First, I recommend to design something on paper or in other non-code frameworks.
# Then create a node and attach a new heir of HFSM to it, and select the new HFSM template.
# Then start from defining export fields: state_name always and animation + backed animation if needed.
# Then work with methods template suggests you: 
# First, if you new heir is a container, feel in the choose_internal_state() method
# or delete it if the new heir is bottom-level state.
# Then write down the transition logic for the new heir in check_transition.
# Then if you need, put some custom initializations or destructors in on_enter() and on_exit() methods
# Then lastly, write the update logic. 
#
# This is the most correct pipeline in my opinion, because the most important thing 
# for any state machine is its transtion logic, 
# and you can test those prior to having any actual updates, if you wrote other methods.
#
# General code guidelines are: use a shit ton of proxies.
# Ideally, your transition logic needs to consist of several if statements that check
# some single function calls with human readable names, almost like a sentence in english.
# I have a bunch of proxies already in this class under the section of syntaxic sugar, don't
# be ashamed to add your own, and define your own proxies in classes if you need. 
# Check the phase one Combat_1 script for example.
# If you need more complex behaviours, try to find a way to solve your problem
# using backend animations framework. You can learn how attacks lifecycle works to
# get the idea, in short, if you need some data, it's probably beneficial for you
# to work with that data with backend animations.
# endregion

func _ready():
	_accept_substates()

## on _ready: automatically builds the inner tree of HFSM
func _accept_substates():
	for child in get_children():
		if child is HFSM:
			is_container = true
			states[child.state_name] = child

# TransitionData has comments in class definition file
# This is a base implementation that fails fast if you forgot to specify the logic.
# Alternatively, you can make the base implementation "lazy" and lock it transitioning nowhere never.
# The plus is that you won't need do specify the method in heirs, the downside is 
# that the failing fast will be lost. Untill you really embraced the workflow, I recommend spamming
# the empty logics in new heirs, then just refactor it into the locked base method when you 
# start to feel comfortable thinking in HFSM designs.
## called in _update
func check_transition(_delta) -> TransitionData:
	return TransitionData.new(true, "implement transition logic for " + state_name) # failing fast
	#return TransitioData.new(false, "")

func choose_internal_state() -> TransitionData:
	return TransitionData.new(true, "implement first state choice logic for " + state_name) # failing fast

## This is being called on physics updates (probably).
## The top level SM needs the method called from somewhere
##    - in this demo we call it from physics update in the top level node Gundyr.
## To override updates use the update(...).
func _update(delta: float):
	# do ur stuff
	update(delta)
		
	if is_container:
		var transition_data = current_state.check_transition(delta)
		if transition_data.needs_switch:
			_switch_to(transition_data.target_state)
		
		# call ur children to do stuff
		current_state._update(delta)

func update(_delta: float):
	pass

func _switch_to(state):
	print("SWITCH ", current_state, " -> ", state)
	if current_state != self:
		current_state._on_exit()
	current_state = states[state]
	current_state._on_enter()
	if not current_state.is_container:
		print("> animation: ", current_state.animation)
		animator.play(current_state.animation)

## internal function, use on_enter() for customisation
func _on_enter():
	mark_enter_state()
	on_enter()
	if is_container:
		var first_state_transition = choose_internal_state()
		_switch_to(first_state_transition.target_state)

## internal function, use on_exit() for customisation
func _on_exit():
	if is_container:
		# todo check: exits on children? there is no condition that current_state is direct children
		# same with other _internal methods i suppose
		current_state._on_exit()
	on_exit()

func on_exit():
	pass

func on_enter():
	pass


## Godot's scene tree is initialised from bottom to top.
## => we need to call this when the whole HFSM is initialized.
## => called in _ready() of the top level node (Gundyr).
func _accept_export_fields():
	for state in states.values():
		state.animator = animator
		state.character = character
		state.player = player
		state.states_data_repo = states_data_repo
		state.resources = resources
		state.weapons = weapons
		if state.is_container:
			state._accept_export_fields()

## Not like other interal functions that use "do your stuff then pass the call down the tree"
## Reactions are heavily defaulted (almost all states react on hit/parry in the same way)
##     => - here is a single default reaction 
##        - it is called once from the bottom leaf, the working state.
## Otherwise, there could be problems like: calling it on each node in the tree and get damaged X times
func _react_on_hit(hit: HitData):
	get_lowest_active_state().react_on_hit(hit)


func react_on_hit(hit: HitData):
	resources.lose_health(hit.damage)

## call this in update method in states that use weapons anyhow
func manage_weapons():
	for weapon in weapons:
		weapon.is_attacking = states_data_repo.is_attacking(weapon.weapon_name, backend_animation, get_progress())

## this needs to be called on_exit of every state that touches weapons
## thanks to how our weapon collision detection works, we have a list of ignored victims for
## an attack. We clear that list on exit from an attack, plus also we deactivate weapons.
func deactivate_weapons():
	for weapon in weapons:
		weapon.hitbox_ignore_list.clear()
		weapon.is_attacking = false


# BACKEND ANIMATION GETTERS
func get_root_position_delta(delta: float):
	return states_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta)

func halberd_hurts() -> bool:
	return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func kick_hurts() -> bool:
	return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func shoulder_hurts() -> bool:
	return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func aura_hurts() -> bool:
	return states_data_repo.get_halberd_hurts(backend_animation, get_progress())
# BACKEND ANIMATION GETTERS ENDS


# TIME MANAGEMENT
func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()

func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time

func works_longer_than(time: float) -> bool:
	return get_progress() >= time

func works_less_than(time: float) -> bool:
	return get_progress() < time

func works_between(start: float, finish: float) -> bool:
	var progress = get_progress()
	return progress >= start and progress <= finish
# TIME MANAGEMENT ENDS


# SUGAR
func get_animation_length() -> float:
	return animator.get_animation(animation).length

func distance_to_player() -> float:
	return character.global_position.distance_to(player.global_position)

func angle_to_player() -> float:
	return character.basis.z.angle_to(projected_direction_to_player())

func direction_to_player() -> Vector3:
	return character.global_position.direction_to(player.global_position)

func projected_direction_to_player() -> Vector3:
	return character.global_position.direction_to(get_projected_player_pos())

func get_projected_player_pos() -> Vector3:
	var player_pos = player.global_position
	player_pos.y = character.global_position.y
	return player_pos

func get_lowest_active_state() -> HFSM:
	if is_container:
		return current_state.get_lowest_active_state()
	return self

func coinflip() -> bool:
	return randi() % 2 == 1

## means that we most probably 1 or 2 frames from the end of the lifecycle
func close_to_the_end_of_animation() -> bool:
	return get_progress() / get_animation_length() > 0.98
# SUGAR ENDS
