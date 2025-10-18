extends Node
# extends StateUtils ?
class_name PlayerState


var player_sm: PlayerSM
var legs_sm: LegsSM
var player: Princess
var combat: PlayerCombat
var area_awareness: AreaAwareness
var anim_container: BaseAnimationContainer
var animator_manager: AnimatorManager


@export var SPEED = 3.0
@export var TURN_SPEED = 2

var skeleton: Skeleton3D
var resources: HumanoidResources
var container: PlayerStatesContainer
var left_wrist: BoneAttachment3D

var initial_position: Vector3

@export var tracking_angular_speed: float = 10
@export var stamina_cost: float = 0

var state_combos: Array # [Combo_]

## Player states have a fixed legs_behavior attached to them. 
var legs_behavior: LegsBehavior
var state_name: String
var priority: int

var current_action: BaseAction
var default_action_name: String # first child or dummy action node

var depends_on_legs: bool = false


var queued_state: String = ""
var forced_state: String = ""


func _has_queued_state() -> bool:
	return queued_state != ""

func _has_forced_state() -> bool:
	return forced_state != ""

func velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	return player.model.__velocity_by_input(input_, delta)


func pm() -> PlayerMovement:
	return player_sm.player_movement

## to override if needed.
func initialise():
	pass

# - does something from the past forces us to switch? 
# - if not, does something from the present modify our inputs? 
# - if not, what vanilla state wants to be defaulted to?
## Not to override
func _check_transition(input_: InputPackage) -> PLVerdict:
	if current_action.allows_queue():
		check_combos(input_)
	if _has_queued_state() and current_action.switches_to_queue():
		print_.psm_check_trans(state_name, "queued 👥 exists, trying it as a force state")
		try_force_state(queued_state)
		queued_state = ""
	if _has_forced_state():
		print_.psm_check_trans(state_name, pp.s("forced 🦾 state prevailed", forced_state, "(specific state checks skipped)"))
		var verdict = PLVerdict.new(forced_state)
		forced_state = "" # forced_state is reset after verdict creation
		return verdict
	
	return check_transition(input_)


## can be overriden: see Run or attack.gd
func check_transition(input_: InputPackage) -> PLVerdict:
	if current_action.time_remaining() <= 0.0:
		print_.psm_check_trans(state_name + " default check", pp.s("time_remaining < 0 => choosing best input"))
		return best_next_state_from_input(input_)
	return PLVerdict.new()


## choosing the input with the highest priority that we can allow
func best_next_state_from_input(input_: InputPackage) -> PLVerdict:
	input_.actions.sort_custom(container.states_priority_sort)
	for action in input_.actions:
		if resources.can_be_paid(container.state_by_name(action)):
			# TODO: just action == state_name?
			if container.state_by_name(action) == self:
				return PLVerdict.new()
			else:
				print_.psm_check_trans(state_name, "best input chosen " + str(action))
				return PLVerdict.new(action)
	return PLVerdict.new("", "best_next_state_from_input() returned nothing!")


func _update(input_: InputPackage, delta: float):
	legs_sm.current_behavior.update(input_, delta)

	if depends_on_legs:
		current_action = legs_sm.current_action

	# if not depends_on_legs and current_action.tracks_input_vector(): # DANGER: depends_on_legs is important
	# 	pm().rotate_with_input_vector_simple(input_, delta)

	update(input_, delta)


func update(input_: InputPackage, _delta: float):
	pass


# looks like can be overriden. Test usage in Run
func choose_default_action() -> String:
	return default_action_name


func _on_enter_state(input_: InputPackage):
	# choose_initial_leg_behavior(input_) # this is advanded use where player state can use legs behavior
	## - single legs beh attached to player state => 
	##    => all is needed is to call the legs SM to switch into this defined state.
	initial_position = player.global_position # used to be here, check
	resources.pay_resource_cost(self)
	
	legs_behavior.player_state = self

	## For now depends_on_legs means legs_behavior is not double. E.g Run or Sprint beh.
	if depends_on_legs:
		print_.psm(state_name + pp.on_ent, "Dependent state. Actions delegated to legs, no action switch here✖️")
		## WARNING testing idle
		if state_name == PS.idle \
			and legs_sm.current_behavior.behavior_name in [Leg.Beh.sprint, Leg.Beh.run, Leg.Beh.strafe]:
			print_.psm(state_name + pp.on_ent, "No switching legs behavior" + em.gray_x)
		else:
			legs_sm.switch_to(legs_behavior, input_)
		on_enter_state(input_)
	else: ## state leads legs.  like Attack or Jump or Midair
		default_action_name = choose_default_action() # NOTE: safe. Container checked that non dependent state has an action.

		print_.psm(state_name + pp.on_ent, "Switch to default action " + default_action_name)
		
		## on_enter_state is before on_action_state
		on_enter_state(input_)
		switch_action_to(default_action_name, input_)
		legs_sm.switch_to(legs_behavior, input_) # NOTE: for now, here is always double


func switch_action_to(next_action_name: String, input_: InputPackage):
	# region: NOTE: we dont check if current action is the same as next_action_name
	# When state was left, it preserved its current_action attribute. On enter it would still have it. 
	# So it is not like we compare here curr action of prev state with next_action_name of new one.
	# We compare curr action of new one from the past with the its next_action_name right now. 
	# And they are probably the same, but switch is needed.
	#
	# In case of problems, consider different approach: reset curr action to null on_exit_state.
	# 
	# See also different mechanic with legs states: current_action belongs to legs_sm, not leg_behavior. 
	# 	=> leg_behavior don't carry its curr action with it.
	# endregion
	if current_action:
		print_.psm("Action ↪️", pp.s("switch action", current_action.action_name, "=>", next_action_name))
	else:
		print_.psm("Action ↪️", "No current action => " + next_action_name)
	current_action = container.action_by_name(next_action_name)
	current_action._on_enter_action(input_)


func on_enter_state(input_: InputPackage):
	pass

func _on_exit_state():
	on_exit_state()
	
func on_exit_state():
	pass


func try_queue_state(new_queued_state: String):
	if not _has_queued_state():
		queued_state = new_queued_state
	elif container.state_by_name(new_queued_state).priority > container.state_by_name(queued_state).priority:
		queued_state = new_queued_state


func try_force_state(new_forced_state: String):
	if not _has_forced_state():
		forced_state = new_forced_state
	elif container.state_by_name(new_forced_state).priority >= container.state_by_name(forced_state).priority:
		forced_state = new_forced_state


## State checks its state_combos if they are triggered.
## If they are, it queues combo's next state
## TODO: If several combos triggered - we will queues the last one. Not critical, but some priority logic needed
func check_combos(input_: InputPackage):
	for combo: Combo_ in state_combos:
		var next_state_candidate = combo.state_to_trigger
		print_.psm_check_trans(state_name, "checking combo " + combo.name + " with state_to_trigger " + next_state_candidate)
		
		if combo.is_triggered(input_) and resources.can_be_paid(container.state_by_name(next_state_candidate)):
			queued_state = next_state_candidate
			print_.psm_check_trans(state_name, "Queued 👥 next state: " + queued_state)


## Updating may be not too far from current state updating: regeneration could be dependent on the current state.
## => define the base state `update_resources` function with delegating the job to the resources.
## -> default regenerations can be defined in the resource class, but it's possible to redefine this function in some states.
## 		for example, to stop stamina from regenerating under a shield block.
func update_resources(delta: float):
		resources.update(delta)


# DEFAULT BEHAVIORS ON MODIFIERS
func react_on_hit(hit: HitData):
	print_.fight(state_name, "react_on_hit called")
	if current_action.is_vulnerable():
		resources.lose_health(hit.damage)
	# if current_action.is_interruptable():
	# 	# TODO rewrite for better effects processing, this scales badly
	# 	# if hit.effects.has("pushback") and hit.effects["pushback"]:
	# 	# 	area_awareness.last_pushback_vector = hit.effects["pushback_direction"]
	# 	# 	try_force_state("pushback")
	# 	# else:
	# 	try_force_state("staggered")

# TODO: ...
func react_on_spell(spell_hit: SpellHitData):
	if current_action.is_vulnerable():
		resources.lose_health(spell_hit.damage)
	if current_action.is_interruptable():
		try_force_state("staggered")
	#spell_hit.queue_free()
	spell_hit.spell.target_contacted(player)

# TODO: ...
# Eg: every parriable weapon strike transitions into a single "parry" state on successful parry
func react_on_parry(_hit: HitData):
	try_force_state("parried")


# region: SOME DOCS
#   check_transition()
# 	BasePlayerState's conditions for transition is generally a simple function based on timings or states of the player.
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
