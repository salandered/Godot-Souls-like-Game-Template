extends EnemyStateUtils
class_name BasePHState

var animator: AnimationPlayer
var states_data_repo: GundyrStatesData
var phe_feelings: PHEFeelings
var weapons: Array[PHWeapon]
var active_weapon: PHWeapon
var container: PHContainer
var combat: PHCombat


var state_name: String
var animation: String

var current_lower_state: BasePHState

##  false if state is a leaf
var is_container: bool = false


## called from above
func _update(delta: float):
	# do ur stuff
	update(delta)
		
	if is_container:
		var verdict = check_transition(delta)
		if verdict.needs_switch():
			__log_phe__upd("verdict.needs_switch() to", verdict.next_state)
			_switch_to(verdict.next_state)
		
		# call ur children to do stuff
		current_lower_state._update(delta)


## To override
func update(_delta: float):
	pass


## called in _update
func check_transition(_delta) -> VerdictPH:
	__log_phe_check("", em.warn, "base check_transition called")
	return VerdictPH.new("", em.warn + "implement transition logic for " + state_name)


func choose_internal_state() -> VerdictPH:
	__log_phe_check("", em.warn, "base choose_internal_state called")
	return VerdictPH.new("", em.warn + "implement first state choice logic for " + state_name)


func _switch_to(state: String):
	__log_phe("↪️", current_lower_state.state_name + " -> " + state)
	if current_lower_state != self:
		current_lower_state._on_exit()
	current_lower_state = container.get_state_by_name(state)
	current_lower_state._on_enter()
	if not current_lower_state.is_container:
		print_.phe_anim("", pp.in_q(current_lower_state.animation))
		animator.play(current_lower_state.animation)


## internal function, use on_enter() to override
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
		# todo check: exits on children? there is no condition that current_lower_state is direct children
		# same with other _internal methods i suppose
		current_lower_state._on_exit()
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
	phe_feelings.lose_health(hit.damage)


## call this in update method in states that use weapons anyhow
func manage_weapons():
	pass
	# combat.update_is_attacking(states_data_repo.is_attacking(active_weapon.weapon_name, backend_animation, get_progress()))
	# for weapon in weapons:
		# weapon.is_attacking = states_data_repo.is_attacking(weapon.weapon_name, backend_animation, get_progress())

## this needs to be called on_exit of every state that touches weapons
## We need to to clear weapon ignore list andto deactivate weapons.
func deactivate_weapons():
	pass
	# for weapon in weapons:
		# weapon.hitbox_ignore_list.clear()
		# weapon.is_attacking = false


# BACKEND ANIMATION GETTERS
# TODO: this is not working right now
func get_root_position_delta(delta: float) -> Vector3:
	return Vector3.ZERO
	# return states_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta)

func halberd_hurts() -> bool:
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func kick_hurts() -> bool:
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func shoulder_hurts() -> bool:
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func aura_hurts() -> bool:
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())


# SUGAR
func get_animation_length() -> float:
	# todo: safer
	if animator.has_animation(animation):
		return animator.get_animation(animation).length
	else:
		print_.warn("Animation " + animation + " not found in animator!")
	return 1.0


func get_lowest_active_state() -> BasePHState:
	if is_container:
		return current_lower_state.get_lowest_active_state()
	return self


## means that we most probably 1 or 2 frames from the end of the lifecycle
func close_to_the_end_of_animation() -> bool:
	return get_progress() / get_animation_length() > 0.98


# region: __LOGS

func _log_state() -> String:
	var _r = state_name
	if state_name == PHEState._TOP:
		_r += "☐"
	else:
		_r += "☘︎" if is_container else "▨"
	return _r

func __log_phe(...parts: Array):
	print_.phe_sm(_log_state(), pp.list_(parts))

func __log_phe_choose(chose_state_: String, ...parts: Array):
	print_.phe_check(_log_state(), "Chose " + chose_state_ + " " + pp.list_(parts))

func __log_phe_check(...parts: Array):
	print_.phe_check(_log_state(), pp.list_(parts))

func __log_phe_ent(...parts: Array):
	print_.phe_sm(_log_state() + pp.on_ent, pp.list_(parts))

func __log_phe_ext(...parts: Array):
	print_.phe_sm(_log_state() + pp.on_ext, pp.list_(parts))

func __log_phe__upd(...parts: Array):
	print_.phe_sm(_log_state() + pp.on_internal_upd, pp.list_(parts))

func __log_phe_upd(...parts: Array):
	print_.phe_sm(_log_state() + pp.on_upd, pp.list_(parts))

# endregion
