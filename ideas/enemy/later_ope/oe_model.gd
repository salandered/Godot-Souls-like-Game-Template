extends CharacterBody3D
class_name Opponent

@export var player: Princess
@export var awake: bool = false
@onready var animator = $AnimationPlayer
@onready var behaviours = $OEStates as OpponentsBehaviourContainer
@onready var brain = $Brain as OpponentBrain
@onready var beliefs = $Beliefs as OpponentBeliefs
@onready var resources = $Resources as OpponentResources

var current_behaviour: OpponentBehaviour


## NOTE IDEA this what player may implement

# func current_attack_locked_time_left() -> float:
# 	if not is_attacking():
# 		return 0
# 	return get_current_state().time_til_priority_release()

# func current_state_posttracking_radius() -> float:
# 	return get_current_state().posttracking_radius


# func roll_time_left() -> float:
# 	return 0
# 	# if is_rolling():
# 	# 	return current_state.DURATION - current_state.get_progress()
# 	# return 0

# func get_roll_endpoint() -> Vector3:
# 	if is_rolling():
# 		return get_current_state().endpoint
# 	return Vector3(1000, 1000, 1000)

# func get_current_state_position_after(time: float) -> Vector3:
# 	# TODO: turned off, code here is obsolete
# 	# var data_track = current_state.backend_animation
# 	# var future = current_state.get_progress() + time
# 	# you can check out the original method usage, it is used to "go back in time"
# 	# but technically nothing stops us from predicting future with it as well
# 	# var predicted_delta_pos = states_data.get_root_delta_pos(data_track, future, time)
# 	# return global_position + get_quaternion() * predicted_delta_pos
# 	return Vector3.UP

# in attack actions:
# func time_til_priority_release() -> float:
# 	return RELEASES_PRIORITY - time_spent()

# in base action
# 
# TODO: interesting but do we need this?
# func time_til_unlocking() -> float:
# 	if tracks_input_vector():
# 		return 0
# 	return states_data_repo.time_til_next_controllable_frame(backend_animation, time_spent())

# endregion
##


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK

	beliefs.player = player
	current_behaviour = behaviours.get_behaviour("idle")
	current_behaviour._on_enter_behaviour()


func _physics_process(delta):
	if current_behaviour._is_open_to_reconsiderations() and awake:
		var most_intended_behaviour = brain.get_most_intended_behaviour()
		if behaviour_needs_to_change(most_intended_behaviour):
			switch_to(most_intended_behaviour)
	current_behaviour._update(delta)

func _unhandled_input(event):
	if event.is_action_pressed("dev_awake_opponent"):
		awake = not awake


func behaviour_needs_to_change(most_intended_behaviour: String) -> bool:
	return not most_intended_behaviour == current_behaviour.behaviour_name or current_behaviour.forced_to_reconsider


func switch_to(next_behaviour: String):
	current_behaviour._on_exit_behaviour()
	current_behaviour = behaviours.get_behaviour(next_behaviour)
	current_behaviour._on_enter_behaviour()


# proxy delegates for cleaner encapsulation
func react_on_hit(hit: HitData):
	current_behaviour.react_on_hit(hit)

func react_on_spell(spell_hit: SpellHitData):
	current_behaviour.react_on_spell(spell_hit)

func force_reconsideration():
	current_behaviour.forced_to_reconsider = true

func form_hit_data(weapon: BaseWeapon) -> HitData:
	return current_behaviour.current_action.form_hit_data(weapon)

func try_force_action(next_action: String):
	current_behaviour.try_force_action(next_action)
