extends BaseCharacterState
## Base class for State Player
## Does many things:
	## manages basic state and action switches.
	## 	  includes high level legs SM switches
	## check transitions, i.e checks when and how to switch itself
	##    includes managing combos and queued/forced states.
	## reacts on external events, like react on hit
## TODO: state became 'too' smart. File is bloated with tons of logic. 
##       think of separating some parts.
##       main idea for now: do checking transitions (combos, etc) on a Player SM level
##       (state is too self aware now)
class_name BasePlayerState

# common
var player_sm: PlayerSM
var legs_sm: LegsSM
var _player: Princess
var combat: PlayerCombat
var area_awareness: AreaAwareness
var anim_container: BaseAnimationContainer
var animator_manager: PlAnimatorManager
var feelings: PlayerFeelings
var container: PlayerStatesContainer

# specific static state data
var priority: int = 0
var stamina_cost: float = 0.0
var stamina_drain: float = 0.0 # experimenting, not in StateData


# state can turn it off if it handles gravity itself. (like midair)
var APPLY_GRAVITY: bool = true

## Player states have a fixed legs_behavior attached to them. 
var legs_behavior: LegsBehavior
var depends_on_legs: bool = false
var default_action_name: String # first child or dummy action node

var state_combos_sorted: Array # [Combo_]

## position of player at the end of the current state
var initial_position: Vector3

# dynamic
var queued_state: MetaState.Queued = MetaState.Queued.new()
var forced_state: MetaState.Forced = MetaState.Forced.new()

var curr_state_action: PlayerAction


func get_player() -> Princess:
	return _player


func curr_global_action() -> BaseAction:
	return player_sm.get_curr_action()


func prev_global_action() -> BaseAction:
	return player_sm.get_prev_action()


func pm() -> PlayerMovement:
	return player_sm.player_movement


## to override if needed.
func initialise() -> void:
	pass

# CHECK TRANSITION
# region

# - does something from the past forces us to switch? 
# - if not, does something from the present modify our inputs? 
# - if not, what vanilla state wants to be defaulted to?
## Not to override
func _check_transition(input_: InputPackage) -> PLVerdict:
	_check_combos(input_)
	if queued_state.is_set() and curr_global_action().switches_to_queue():
		__log_psm_check("queued 👥 exists, trying it as a force state")
		forced_state.try_set_from_another(queued_state, true)
		queued_state.reset() # important!
	if forced_state.is_set():
		__log_psm_check(forced_state, "prevailed", " (specific state checks skipped)")
		var verdict := PLVerdict.new(forced_state.get_state_name())
		forced_state.reset() # forced_state is reset after verdict creation
		return verdict
	
	return check_transition(input_)


## can be overriden
func check_transition(input_: InputPackage) -> PLVerdict:
	if curr_global_action().time_remaining() <= 0.0:
		__log_psm_check("[default check]", "time_remaining < 0 and non looping => choosing best input")
		return best_next_state_from_input(input_)
	return PLVerdict.new()


## choosing the input with the highest priority that we can allow
func best_next_state_from_input(input_: InputPackage) -> PLVerdict:
	var _input_actions_sorted := container.states_sort_by_priority(input_.actions)
	for input_action: String in _input_actions_sorted:
		if _check_feelings_can_be_paid(input_action):
			if input_action == state_name: # we
				return PLVerdict.new()
			else:
				__log_psm_check("best input chosen ", input_action)
				return PLVerdict.new(input_action)
	return PLVerdict.new("", "best-next-state-from-inp returned nothing! return empty verdict")


func _check_feelings_can_be_paid(input_action: String) -> bool:
	var _stamina_cost := container.state_by_name(input_action).stamina_cost
	var _stamina_drain := container.state_by_name(input_action).stamina_drain
		
	if feelings.can_be_paid(_stamina_cost) and feelings.can_allow_stamina_drain(_stamina_drain):
		return true
	__log_psm_check(em.black_h, "can't pay for state", input_action, "cost", _stamina_cost, "drain", _stamina_drain)
	return false


## State checks its state_combos_sorted if they are triggered. 
## If they are, it queues combo's next state.
## Combos are sorted by their priority: highest to lowest.
func _check_combos(input_: InputPackage):
	for combo: Combo_ in state_combos_sorted: # by priority
		var next_state_candidate := combo.state_to_trigger
		# __log_psm_check("checking combo", combo.name, "with state_to_trigger", next_state_candidate)
		var _state := container.state_by_name(next_state_candidate)
		if combo.is_triggered(input_, state_name, curr_global_action()):
			if feelings.can_be_paid(_state.stamina_cost):
				queued_state.set_state(next_state_candidate, _state.priority) # todo: try_set_queued_state
				__log_psm_check("Queued 👥 next state: ", queued_state)
				return # prioritised combo finishes checks
			else:
				__log_psm_check("Combo trigger can't pay stamina", _state.stamina_cost)

# endregion

func call_accumulate_time_spent(delta: float) -> void:
	accumulate_time_spent(delta)


func _update(input_: InputPackage, delta: float):
	call_accumulate_time_spent(delta)

	_update_feelings(delta)
	legs_sm.current_behavior.update(input_, delta)
	curr_state_action._update(input_, delta)
	update(input_, delta)

	if APPLY_GRAVITY:
		if area_awareness.is_on_floor():
			pass
		## apply gravity if we close to the floor without changing state
		elif area_awareness.is_almost_on_floor():
			var _applied := pm().apply_gravity(delta, 2.0)
			if _applied:
				__log_state_upd("applied gravity ☄️")
		else:
			forced_state.try_set(PS.midair, 50)


func _update_feelings(delta: float):
	feelings._update(delta, stamina_drain)


## to override
func update(input_: InputPackage, delta: float):
	pass


# looks like can be overriden. Test usage in Run
func choose_default_action() -> String:
	return default_action_name


func _on_enter_state(input_: InputPackage):
	mark_enter_state()
	# choose_initial_leg_behavior(input_) # this is advanded use where _player state can use legs behavior
	## - single legs beh attached to _player state => 
	##    => all is needed is to call the legs SM to switch into this defined state.
	initial_position = _player.global_position
	feelings.pay_state_cost(stamina_cost)
	
	legs_behavior.player_state = self

	## For now depends_on_legs means legs_behavior is not double. E.g Run or Sprint beh.
	if depends_on_legs:
		__log_state_ent("Dependent state. Actions delegated to legs, no state action switch✖️ - double")
		on_enter_state(input_)
		switch_action_to(PS.Act.double, input_)
		## WARNING testing idle
		if state_name == PS.idle \
			and legs_sm.current_behavior.behavior_name in [Leg.Beh.sprint, Leg.Beh.run, Leg.Beh.strafe]:
			__log_state_ent("No switching legs behavior", em.gray_x)
		else:
			legs_sm.switch_to(legs_behavior, input_)
	else: ## state leads legs.  like Attack or Jump or Midair
		default_action_name = choose_default_action() # NOTE: safe. Container checked that non dependent state has an action.

		__log_state_ent("Switch to default action", pp.in_q(default_action_name))
		
		
		switch_action_to(default_action_name, input_)
		on_enter_state(input_) ## on_enter_state should be before on_action_state | OF AFTER?
		legs_sm.switch_to(legs_behavior, input_) # NOTE: for now, here is always double


func switch_action_to(next_action_name: String, input_: InputPackage):
	# region: NOTE: we dont check if current action is the same as next_action_name
	# When state was left, it preserved its curr_state_action attribute. On enter it would still have it. 
	# So it is not like we compare here curr action of prev state with next_action_name of new one.
	# We compare curr action of new one from the past with the its next_action_name right now. 
	# And they are probably the same, but switch is needed.
	#
	# In case of problems, consider different approach: reset curr action to null on_exit_state.
	# 
	# See also different mechanic with legs states: curr_state_action belongs to legs_sm, not leg_behavior. 
	# 	=> leg_behavior don't carry its curr action with it.
	# endregion
	if curr_state_action and curr_state_action.action_name == PS.Act.double and next_action_name == PS.Act.double:
		# print_.psm("Action ↪️", "Double to double => no switch.")
		return
	if curr_state_action:
		print_.psm("Action ↪️", pp.s("switch action", curr_state_action.action_name, "=>", next_action_name))
		curr_state_action._on_exit_action()
	else:
		print_.psm("Action ↪️", "No current action => " + next_action_name)

	var next_action := container.pl_action_by_name(next_action_name)
	next_action._on_enter_action(input_)


func on_enter_state(input_: InputPackage):
	pass

func _on_exit_state() -> void:
	queued_state.reset()
	forced_state.reset()
	on_exit_state()
	
func on_exit_state() -> void:
	pass


# region: REACTION


func react_on_hit(hit: HitData):
	print_.fight(state_name, "we received a hit " + str(hit))

	## 1 - check if we need to change state
	## 2 - if not, we delegate reaction behavior to curr action
	var react_state_name := ReactionOnHit.calculate_reaction_for_pl_state(hit)
	if react_state_name:
		__log_state_upd("hit leaded to react state", react_state_name)
		var state := container.state_by_name(react_state_name)
		forced_state.try_set(react_state_name, state.priority)
	else:
		curr_global_action()._react_on_hit(hit)


# TODO: ...
# func react_on_spell(spell_hit: SpellHitData):
# 	if curr_global_action().is_vulnerable():
# 		feelings.lose_health(spell_hit.damage)
# 	# if curr_global_action().is_interruptable():
# 		# forced_state.try_set("staggered", 0)
# 	#spell_hit.queue_free()
# 	spell_hit.spell.target_contacted(_player)

# TODO: ...
# Eg: every parriable weapon strike transitions into a single "parry" state on successful parry
func react_on_parry(_hit: HitData):
	pass
	# try_set_force_state("parried")

# endregion

# region: SOME DOCS
#   check_transition()
# 	BasePlayerState's conditions for transition is generally a simple function based on timings or states of the _player.
#	If check_transition is a complex method, another state or usage of Combo_
#
#   update() functions manages perframe behavior of your BasePlayerState.
#	There are two update types: 
#	    - constant change
#       - single dynamic update on some timing.
#	To implement simple constant changes, try to find physics abstraction for them to make
#	engine work for you. If changes are too complex, try to avoid hardcoding the behavior into 
#   a giant update, better delegate the changes to backend animation or some other system.

#	To implement timed changes, use a flag and work with timings via get_progress() etc.
# endregion


# region: LOGS

func __log_warn(crucial: bool, what: String, where: String, fallback: String, ...details: Array):
	print_.warn(crucial, what, where + "| in state " + pp.in_q(state_name), fallback, pp.list_(details))


func __log_state_ent(...parts: Array):
	print_.psm(state_name + pp.on_ent, pp.list_(parts))

func __log_state_exit(...parts: Array):
	print_.psm(state_name + pp.on_ext, pp.list_(parts))

func __log_state_upd(...parts: Array):
	print_.psm(state_name + pp.on_upd, pp.list_(parts))


func __log_psm_check(...parts: Array):
	print_.psm_check_trans(state_name, pp.list_(parts))

func __log_time_spent():
	print_.psm(state_name, pp.s("Time spent: state -", get_actual_time_spent(), "action - ", curr_state_action.time_spent()))


# endregion
