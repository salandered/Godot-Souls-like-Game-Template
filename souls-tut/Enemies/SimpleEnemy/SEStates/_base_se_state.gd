extends EnemyStateUtils
class_name BaseSEState
# TODO Consider: Common ancestor class State for BaseSEState and BaseSEState
#  - player state relies on input-dependent transitions and updates, whereas the enemy state does not
#    => only some fields and reaction logic would be shared, making the classes similar but not unified

var state_name: String
var animation: String


var container: SEStatesContainer
var animator: SEAnimator
var resources: EnemyResources
var right_weapon: WeaponOh
var traits: TraitsContainer

var spawn_point: Vector3


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _check_transition(delta: float) -> String:
	# if not me.is_on_floor() and not me.current_state.name == SEState.death:
		# return SEState.midair
	me.velocity.y -= gravity * delta
	

	return check_transition(delta)


## default check_transition. to override
func check_transition(delta) -> String:
	# if works longer than too much than do something calm
	return me.CURRENT


func _update(delta: float):
	update(delta)

func update(delta: float):
	pass


func _on_enter_state():
	mark_enter_state()
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
