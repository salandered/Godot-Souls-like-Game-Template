extends Node
# extends StateUtils ?
class_name PlayerState


var player_sm: PlayerSM
var legs_sm: LegsSM
var player: Princess
var combat: HumanoidCombat
var area_awareness: AreaAwareness
var anim_container: AnimationContainer
var enter_state_time: float

@export var SPEED = 3.0
@export var TURN_SPEED = 2

var skeleton: Skeleton3D
var resources: HumanoidResources
var container: PlayerStatesContainer
var left_wrist: BoneAttachment3D

var initial_position: Vector3

@export var tracking_angular_speed: float = 10
@export var settings_switch_time: float = 0.2
@export var stamina_cost: float = 0

@onready var state_combos: Array[Combo_]

## torso states just have a fixed legs_behavior attached to them. 
## It is simply wired in the editor via an export field. 
var legs_behavior: LegsBehavior
var state_name: String
var priority: int

var current_action: BaseAction
var default_action_name: String # first child or dummy action node

var depends_on_legs: bool = false


var queued_state: String = ""
var forced_state: String = ""


func has_queued_state() -> bool:
	return queued_state != ""

func has_forced_state() -> bool:
	return forced_state != ""

func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	return player_sm.__velocity_by_input(input, delta)

# ep 4: When a transition occurs, we ask three questions: 
# 1. does something from the past force us to transition somewhere? 
# 2. If not, does something textual from the present modify our inputs? 
# 3. if nothing above, what vanilla state wants to default to?
## Not to override
func _check_transition(input: InputPackage) -> PLVerdict:
	# if current_action.action_name == PS.action_longsword_1: # old dev print 
		# print_.combo("", str(current_action.accepts_queueing()))
	if current_action.allows_queue():
		check_combos(input)
	if has_queued_state() and current_action.switches_to_queue():
		print_.psm_check_trans(state_name, "queued 👥 exists, trying it as a force state")
		try_force_state(queued_state)
		queued_state = ""
	if has_forced_state():
		print_.psm_check_trans(state_name, "forced 🦾 state prevailed" + forced_state + " (specific state checks skipped)")
		var verdict = PLVerdict.new(forced_state)
		forced_state = "" # forced_state is emptied after verdict creation
		return verdict
	
	## can be overriden	# used to be called default lifecycle
	return check_transition(input)


## can be overriden: see Run or attack.gd
func check_transition(_input: InputPackage) -> PLVerdict:
	if current_action.works_longer_than(current_action.DURATION):
		print_.psm_check_trans(state_name + " default checks", "works longer than " + str(current_action.DURATION) + " => choosing best input")
		return best_input_that_can_be_paid(_input)
	return PLVerdict.new()

## choosing the input with the highest priority that we can allow
func best_input_that_can_be_paid(input: InputPackage) -> PLVerdict:
	input.actions.sort_custom(container.states_priority_sort)
	for action in input.actions:
		if resources.can_be_paid(container.state_by_name(action)):
			# TODO: just action == state_name?
			if container.state_by_name(action) == self:
				return PLVerdict.new()
			else:
				print_.psm_check_trans(state_name, "best input choosen " + str(action))
				return PLVerdict.new(action)
	return PLVerdict.new("", "throwing because for some reason input.actions is empty")


func _update(input: InputPackage, delta: float):
	legs_sm.current_behavior.update(input, delta)

	if depends_on_legs:
		current_action = legs_sm.current_action

	if not depends_on_legs and current_action.tracks_input_vector(): # DANGER: depends_on_legs is important
		process_input_vector(input, delta)


	update(input, delta)

func update(_input: InputPackage, _delta: float):
	pass

# looks like can be overriden. Test usage in Run
func choose_default_action() -> String:
	return default_action_name


func _on_enter_state(input: InputPackage):
	# choose_initial_leg_behavior(input) # this is advanded use where torso state can use legs behavior
	## - single legs beh attached to player state => all we need is to forcibly call the legs SM to switch into this defined state.
	# used to be here
	initial_position = player.global_position
	resources.pay_resource_cost(self)
	# mark_enter_state()
	
	
	legs_behavior.player_state = self # duplicates legs_sm.switch_to logic?

	# TODO: stupid split. or not?
	if depends_on_legs: # like Run state or Sprint state
		player_sm.full_body_animator.sync_and_follow(legs_sm.legs_animator, 0.15)
		print_.psm("state", "enter: DEPENDENT state. Actions delegated to legs, NO SWITCHES ⚪⚪", 1)
		legs_sm.switch_to(legs_behavior, input)
	else: # state leads legs.  like Attack or Jump or Midair
		#if legs_behavior.behavior_name != LS.legs_behavior_double:
			#push_warning("we found state which leads legs but not double legs. Investigate!!")
		default_action_name = choose_default_action()
		assert(default_action_name, state_name + " No default actions for non depended state which is probably an error ")
		# if not default_action_name:
			# print_.psm("enter ", state_name + " No default actions for non depended state which is probably an error ", 1)

		print_.psm("enter", " switch to DEFAULT action " + default_action_name, 1)
		switch_action_to(default_action_name, input)
		legs_sm.switch_to(legs_behavior, input)

	on_enter_state(input)


func switch_action_to(next_action_name: String, input: InputPackage):
	if current_action and current_action.action_name == next_action_name:
		print_.psm("Action", "same next action ⚪ NO SWITCH to " + next_action_name, 1)
		return
	if current_action:
		print_.psm("Action", "switch action " + current_action.action_name + " => " + next_action_name, 1)
	else:
		print_.psm("Action", "No current action ⚪ => " + next_action_name, 1)
	current_action = container.action_by_name(next_action_name)
	current_action._on_enter_action(input)


# func choose_initial_leg_behavior(input: InputPackage):
	# pass

func on_enter_state(_input: InputPackage):
	pass

func _on_exit_state():
	current_action = null # do we need it?
	on_exit_state()
	
func on_exit_state():
	pass


# func setup_legs_animator(previous_action: LegsAction, input: InputPackage):
# 	pass


func try_queue_state(new_queued_state: String):
	if not has_queued_state():
		queued_state = new_queued_state
	elif container.state_by_name(new_queued_state).priority > container.state_by_name(queued_state).priority:
		queued_state = new_queued_state

func try_force_state(new_forced_state: String):
	if not has_forced_state():
		forced_state = new_forced_state
	elif container.state_by_name(new_forced_state).priority >= container.state_by_name(forced_state).priority:
		forced_state = new_forced_state


## State asks its state_combos if they are triggered.
## If they are, it queues combo's next state
## TODO: If several combos triggered - we will queues the last one. Not critical, but some priority logic needed
func check_combos(input: InputPackage):
	for combo: Combo_ in state_combos:
		var next_state_candidate = combo.state_to_trigger
		print_.psm_check_trans(state_name, "checking combo " + combo.name + " with state_to_trigger " + next_state_candidate)
		
		if combo.is_triggered(input) and resources.can_be_paid(container.state_by_name(next_state_candidate)):
			queued_state = next_state_candidate
			print_.psm_check_trans(state_name, "Queued 👥 next state: " + queued_state, 1)


## Updating may be not too far from current state updating: regeneration could be dependent on the current state.
## => define the base state `update_resources` function with delegating the job to the resources.
## -> default regenerations can be defined in the resource class, but it's possible to redefine this function in some states.
## 		for example, to stop stamina from regenerating under a shield block.
func update_resources(delta: float):
		resources.update(delta)

## default implementation
## To redefine the processing, override the method in the state script.
## To stop the direction input completely for a state
##     - either false the backend track, or redefine the state getter for the window to return false
##     - or override the processing with pass
func process_input_vector(input: InputPackage, delta: float):
	# var input_direction = (player.camera_mount.basis * Vector3(-input.input_direction.x, 0, -input.input_direction.y)).normalized()
	# todo: this is that strange valocity chain
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	player.rotate_y(clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))


func assign_combos():
	for child in get_children():
		if child is Combo_:
			print_.prefix("Container", "For state " + state_name + " assigned combo " + child.name, 0, L.INFO)
			state_combos.append(child)
			child.state = self

## overidden in states
func pack_hit_data(_weapon: BaseWeapon) -> HitData:
	print("someone tries to get hit by default State")
	return HitData.blank()


# DEFAULT BEHAVIORS ON MODIFIERS
#  - most of our states react on being hit universally
#    they check for interruptibility frames and do stagger (or don't). 
func react_on_hit(hit: HitData):
	# print("BaseState: react_on_hit called")
	if current_action.is_vulnerable():
		resources.lose_health(hit.damage)
	if current_action.is_interruptable():
		# TODO rewrite for better effects processing, this scales badly
		if hit.effects.has("pushback") and hit.effects["pushback"]:
			area_awareness.last_pushback_vector = hit.effects["pushback_direction"]
			try_force_state("pushback")
		else:
			try_force_state("staggered")

func react_on_spell(spell_hit: SpellHitData):
	if current_action.is_vulnerable():
		resources.lose_health(spell_hit.damage)
	if current_action.is_interruptable():
		try_force_state("staggered")
	#spell_hit.queue_free()
	spell_hit.spell.target_contacted(player)


# Eg: every parriable weapon strike transitions into a single "parry" state on successful parry
func react_on_parry(_hit: HitData):
	try_force_state("parried")


#func change_animation_to(animation_: String):
	#if animation != animation_:
		#animation = animation_
		#if backend_animation == A.to_backend_lazy(animation):
			#push_error("probably unreachable")
		#backend_animation = A.to_backend_lazy(animation)
		#animator.update_body_animations()


# region: SOME DOCS
#   check_transition()
# 	BasePlayerState conditions for transition is generally a simple function based on timings or states of the player.
#	If check_transition is a complex method, another state or usage of Combo_
#
#   update() functions manages perframe behavior of your BasePlayerState.
#	There are two update types: 
#	     constant change
#        single dynamic update on some timing.
#	To implement simple constant changes, try to find physics abstraction for them to make
#	engine work for you. If changes are too complex, try to avoid hardcoding 
#	the behavior into a giant update, better delegate the changes to backend animation or
#	some other system.
#	To implement timed changes, use a flag and work with timings via get_progress() etc.
# endregion
