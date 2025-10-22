## A simple locked-in animation. It just transports the player while marking him as invincible. 

extends PlayerState

# the point where we predict the roll will end
# (no physics simulations currently, just a vector add up)
# used to communicate with enemies
var endpoint: Vector3

func update(input_: InputPackage, delta):
	move_player(delta)


func move_player(delta: float):
	# var delta_pos = curr_state_action.get_root_position_delta(delta)
	# delta_pos.y = 0
	# var rotated_delta = player.get_quaternion() * delta_pos / delta
	# player.velocity.x = rotated_delta.x
	# player.velocity.z = rotated_delta.z
	if not player.is_on_floor():
		player.velocity.y -= u.gravity * delta

# TODO To move this reset logic into the base State? 
# It’s a quick hack for one‑shot animations that can chain (e.g. roll → roll). 
#   - Because our animations are decoupled from timing, we sometimes end up one frame late.
#   - Without this hack, chaining roll→roll will hold the final pose of the first roll during the second.
#   - Currently Parry State also uses this (parries can be spammed) 
#   - But I’d rather avoid adding another exported bool.
func on_enter_state(input_):
	# animator.reset_torso_animation()
	# animator.reset_legs_animation()
	# In DS3 walk uses smooth 180° turns; roll snaps instantly.
	# To snap on roll’s `_on_enter`, we need the input vector.
	# Two options: pass input to every `_on_enter` or cache it in an area‑awareness layer.
	# I cache the last input, so roll’s `_on_enter` grabs it and snaps direction.
	# After snapping, roll remains locked—no further input or rotation until animation ends.
	# TODO: velocity_by_input here needs delta ... 
	var input = area_awareness.last_input_package
	#var input_direction := velocity_by_input(input_, delta).normalized()
	#if input_direction:
		#player.look_at(player.global_position + input_direction, Vector3.UP, true)


func best_next_state_from_input(input_: InputPackage) -> PLVerdict:
	input_.actions.sort_custom(container._states_priority_sort)
	for action in input_.actions:
		if feelings.can_be_paid(container.state_by_name(action).stamina_cost):
			return PLVerdict.new(action)
			#if container.states[action] == self:
				#PLVerdict.new("")
			#else:
				#return action
	return PLVerdict.new("", "throwing because for some reason input.actions doesn't contain even idle")
