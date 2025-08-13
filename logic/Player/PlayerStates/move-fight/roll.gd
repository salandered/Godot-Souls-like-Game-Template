## A simple locked-in animation. It just transports the player while marking him as invincible. 

extends BasePlayerState

# the point where we predict the roll will end
# (no physics simulations currently, just a vector add up)
# used to communicate with enemies
var endpoint: Vector3

func update(_input: InputPackage, delta):
	move_player(delta)


func move_player(delta: float):
	var delta_pos = get_root_position_delta(delta)
	delta_pos.y = 0
	var rotated_delta = player.get_quaternion() * delta_pos / delta
	player.velocity.x = rotated_delta.x
	player.velocity.z = rotated_delta.z
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	player.move_and_slide()

# TODO To move this reset logic into the base State? 
# It’s a quick hack for one‑shot animations that can chain (e.g. roll → roll). 
#   - Because our animations are decoupled from timing, we sometimes end up one frame late.
#   - Without this hack, chaining roll→roll will hold the final pose of the first roll during the second.
#   - Currently Parry State also uses this (parries can be spammed) 
#   - But I’d rather avoid adding another exported bool.
func on_enter_state():
	# animator.reset_torso_animation()
	# animator.reset_legs_animation()
	

	# In DS3 walk uses smooth 180° turns; roll snaps instantly.
	# To snap on roll’s `_on_enter`, we need the input vector.
	# Two options: pass input to every `_on_enter` or cache it in an area‑awareness layer.
	# I cache the last input, so roll’s `_on_enter` grabs it and snaps direction.
	# After snapping, roll remains locked—no further input or rotation until animation ends.
	
	# TODO: velocity_by_input here needs delta ... 
	var input = area_awareness.last_input_package
	#var input_direction := velocity_by_input(input, delta).normalized()
	#if input_direction:
		#player.look_at(player.global_position + input_direction, Vector3.UP, true)


func best_input_that_can_be_paid(input: InputPackage) -> String:
	input.actions.sort_custom(container.states_priority_sort)
	for action in input.actions:
		if resources.can_be_paid(container.states[action]):
			return action
			#if container.states[action] == self:
				#return "okay"
			#else:
				#return action
	return "throwing because for some reason input.actions doesn't contain even idle"
