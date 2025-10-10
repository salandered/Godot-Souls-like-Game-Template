extends EnemyStateUtils
class_name BaseHSMEState

var animator: AnimationPlayer
var states_data_repo: GundyrStatesData
var resources: HFSMResources
var weapons: Array[BaseWeapon]
var container: HSMStatesContainer


# These fields must be set for each state indivdually.
# Container states have empty string for animation and backend_animation
var state_name: String
var animation: String
var backend_animation: String

var current_state: BaseHSMEState = self

##  false if state is a leaf
var is_container: bool = false


## We call it from physics update in the top level of HSMECharacter.
func _update(delta: float):
	# do ur stuff
	update(delta)
		
	if is_container:
		var verdict = current_state.check_transition(delta)
		if verdict.needs_switch():
			_switch_to(verdict.next_state)
		
		# call ur children to do stuff
		current_state._update(delta)


## To override
func update(_delta: float):
	pass

## called in _update
func check_transition(_delta) -> VerdictHSM:
	return VerdictHSM.new("", "implement transition logic for " + state_name)


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new("", "implement first state choice logic for " + state_name)


func _switch_to(state: String):
	print_.hsme("↪️", current_state.state_name + pp.arr + state)
	if current_state != self:
		current_state._on_exit()
	current_state = container.get_state_by_name(state)
	current_state._on_enter()
	if not current_state.is_container:
		print_.hsme("▶️ animation: ", current_state.animation, 4)
		animator.play(current_state.animation)

## internal function, use on_enter() to verride
func _on_enter():
	mark_enter_state()
	on_enter()
	if is_container:
		var first_state_transition = choose_internal_state()
		_switch_to(first_state_transition.next_state)

## internal function, use on_exit() to override
func _on_exit():
	if is_container:
		# upd: what i meant here?
		# todo check: exits on children? there is no condition that current_state is direct children
		# same with other _internal methods i suppose
		current_state._on_exit()
	on_exit()

func on_exit():
	pass

func on_enter():
	pass


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
## We need to to clear weapon ignore list andto deactivate weapons.
func deactivate_weapons():
	for weapon in weapons:
		weapon.hitbox_ignore_list.clear()
		weapon.is_attacking = false


# BACKEND ANIMATION GETTERS
# TODO: this is not working right now
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


# SUGAR
func get_animation_length() -> float:
	# todo: safer
	return animator.get_animation(animation).length


func get_lowest_active_state() -> BaseHSMEState:
	if is_container:
		return current_state.get_lowest_active_state()
	return self


## means that we most probably 1 or 2 frames from the end of the lifecycle
func close_to_the_end_of_animation() -> bool:
	return get_progress() / get_animation_length() > 0.98


# region >>> OLD DOCS <<<
# Design something on paper.
# Then create a node and attach a new heir of BaseHSMEState to it.
# Then start from defining fields in container: state_name always and animation + backed animation if needed.
# If you new heir is a container, feel in the choose_internal_state() method
# 	or delete it if the new heir is bottom-level state.
# Then write down the transition logic for the new heir in check_transition.
# Then if you need, put some custom initializations or destructors in on_enter() and on_exit() methods.
# Lastly, write the update logic. 
# endregion
