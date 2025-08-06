extends EnemyStateUtils
class_name BaseSEState
# TODO Consider: Common ancestor class State for BaseSEState and BaseSEState
#  - player state relies on input-dependent transitions and updates, whereas the enemy state does not
#    => only some fields and reaction logic would be shared, making the classes similar but not unified

var state_name: String
var animation: String
var backend_animation: String
var global_commitment: float
var iteration_commitment: float
var fatigue: float

var container: SEStatesContainer
var animator: SEAnimator
var resources: EnemyResources
var right_weapon: WeaponOh
var traits: TraitsContainer

var spawn_point: Vector3

var __print_counter := 0
var __frequency := 10

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _check_transition(delta: float) -> String:
	if not me.is_on_floor() and not me.current_state.name == SEState.death:
		return SEState.midair

	var verdict = check_transition(delta)

	__print_counter += 1
	# if __print_counter % __frequency == 0:
		# print_.prefix("SE", "~~ " + str(get_iteration_progress()) + " / " + str(get_progress()) + " ~~ ")

	if iteration_works_less_than(iteration_commitment) and verdict != me.CURRENT and verdict != me.CURRENT_NEW_ITER:
		print_.prefix("SE", state_name + ": iteration_works_less. " + verdict + " rejected")
		# here no mark_state_iteration(), we are still in the same iteration
		return me.CURRENT

	if verdict != me.CURRENT and verdict != me.CURRENT_NEW_ITER:
		print_.prefix("||||SE", verdict + " not rejected ", 2)
	
	# i quess global_commitment and fatigue should be decided in the state itself

	if verdict == me.CURRENT_NEW_ITER:
		print_.prefix("SE", state_name + ": new iteration, mark_state_iteration", 2)
		iteration_mark_state()
	return verdict


## default check_transition. to override
func check_transition(delta) -> String:
	# if works longer than too much than do something calm
	return me.CURRENT


func _update(delta: float):
	update(delta)

func update(delta: float):
	pass


func _on_enter_state():
	print_.prefix("SE", ">>> mark timers", 2)
	mark_enter_state()
	iteration_mark_state()
	on_enter_state()
	animator.update_animation()

func on_enter_state():
	pass

func _on_exit_state():
	on_exit_state()

func on_exit_state():
	pass


func react_on_hit(hit: HitData):
	print("BaseSEState: react_on_hit called")
	print("Hit Data: ", hit)
	resources.lose_health(hit.damage)


func change_animation_to(animation_: String):
	if animation != animation_:
		animation = animation_
		# if backend_animation == A.to_backend_lazy(animation):
			# push_error("probably unreachable")
		# backend_animation = A.to_backend_lazy(animation)
		animator.update_animation()
