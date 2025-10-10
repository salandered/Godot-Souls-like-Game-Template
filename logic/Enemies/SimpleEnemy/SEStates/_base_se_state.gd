extends EnemyStateUtils
class_name BaseSEState

var state_name: String
var animation: String
var backend_animation: String

## global_commitment is how long enemy should persist doing current state
## iteration_commitment is how long enemy should persist doing current state after last deciding to continue it
## fatigue is how long enemy should persist doing current state before calming down
var global_commitment: float
var iteration_commitment: float
var fatigue: float

var container: SEStatesContainer
var animator: SEAnimator
var resources: EnemyFeelings
var right_weapon: BaseWeapon
var traits: TraitsContainer

var spawn_point: Vector3

var __rejected: int = 0 # only for convinient debug prints

func _check_transition(delta: float) -> SEVerdict:
	if not me.is_on_floor() and not me.current_state.name == SEState.death:
		return SEVerdict.new(SEState.midair)

	var verdict = check_transition(delta)
	
	# print_.se("", "~~ " + str(get_iteration_progress()) + " / " + str(get_progress()) + " ~~ ", 0, "", 4)

	# here no mark_state_iteration(), we are still in the same iteration
	if iteration_works_less_than(iteration_commitment) and not verdict.is_current():
		if __rejected < 2: print_.se_check_trans(state_name, "iteration < commitment. => " + verdict.next_state + " rejected ✖️", 2)
		__rejected += 1
		return SEVerdict.new()
	__rejected = 0

	# i quess global_commitment and fatigue should be decided in the state itself
	if verdict.request_new_iter:
		print_.se_check_trans(state_name, "new iteration requested => same state, iter-mark-state", 2)
		iteration_mark_state()
		return SEVerdict.new("", true)

	print_.se_check_trans(state_name, "final verdict", 3)
	return verdict


## Default check_transition to override. 
## Called at the beginning of generic _check_transition.
func check_transition(delta: float) -> SEVerdict:
	print_.se_check_trans(state_name, "DEFAULT check_transition returns CURRENT", 3)
	return SEVerdict.new()


func _update(delta: float):
	update(delta)

func update(delta: float):
	pass


func _on_enter_state():
	print_.se(state_name, "on_enter_state. Mark all timers", 1)
	mark_enter_state()
	iteration_mark_state()
	on_enter_state()
	animator.update_animation()

func on_enter_state():
	pass

func _on_exit_state():
	on_exit_state()

func on_exit_state():
	print_.se(state_name, "on_exit_state", 1)
	pass


func react_on_hit(hit: HitData):
	print("BaseSEState: react_on_hit called")
	print("Hit Data: ", hit)
	resources.lose_health(hit.damage)


func change_animation_to(animation_: String):
	if animation != animation_:
		animation = animation_
		animator.update_animation()
