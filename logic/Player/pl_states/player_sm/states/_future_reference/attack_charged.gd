extends PlayerState


# # CHARGED ATTACK IS USED FOR REFERENCE FOR NOW
# @export var releases_priority: float = 0.8333
# @export var tracking_angular_speed: float = 20

# var double_action: LegsAction

# func update_legs(input: InputPackage, delta: float):
# 	process_input_vector(input, delta)
# 	move_with_root(delta)

# func process_input_vector(input: InputPackage, delta: float):
# 	if tracks_input_vector():
# 		var input_direction = camera.basis * input.get_vector3()

# 		var face_direction = player.basis.z
# 		var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
# 		var new_z = player.basis.z.rotated(Vector3.UP, clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
# 		var new_x = - new_z.cross(Vector3.UP)
# 		player.basis = Basis(new_x, Vector3.UP, new_z).orthonormalized()

# func move_with_root(_delta: float):
# 	var current_rotation = player.get_quaternion()
# 	var velocity: Vector3 = current_rotation * double_action.animator.calculate_root_velocity()
# 	player.set_velocity(velocity)
# 	#seek_land(delta)
# 	player.move_and_slide()

# func transition_logic(input: InputPackage) -> String:
# 	input = translate_actions_to_behaviors(input)
# 	if current_action.action_name == "release":
# 		var best_input = best_input_that_can_be_paid(input)
# 		if current_action.acts_longer_than(releases_priority) and best_input.next_state != "run": # TODO != base locomoti
# 			return best_input
# 		if current_action.animation_ended():
# 			return best_input
# 	return PLVerdict.new("")

# func translate_actions_to_behaviors(input: InputPackage) -> InputPackage:
# 	input = map_with_dictionary(input, behavior_map)
# 	input.behavior_names.append("run") # TODO smth like append default locomotion mode that is walk/run/crouc
# 	return input

# #func on_enter_behavior(input : InputPackage):
# #	switch_action_to("charge", input)

# func choose_initial_behavior(input: InputPackage):
# 	switch_action_to("charge", input)
# 	legs_behavior = legs_sm.behavior_by_name("double_legs")
# 	#legs_behavior = legs_sm.behavior_by_name("combat_walk_legs")

# func update(input: InputPackage, _delta: float):
# 	choose_action(input)

# func choose_action(input: InputPackage):
# 	if current_action.action_name == "charge" and current_action.animation_ended():
# 		legs_sm.switch_to(legs_sm.behavior_by_name("combat_walk_legs"), input)
# 		switch_action_to("hold", input)
# 		return
# 	if current_action.action_name == "hold" and not input.behavior_names.has("SNS_charged_attack"):
# 		switch_action_to("release", input)
# 		legs_sm.switch_to(legs_sm.behavior_by_name("double_legs"), input)
# 		return

# func setup_legs_animator(previous_action: LegsAction, _input: InputPackage):
# 	print("requested legs animator setup")
# 	double_action = legs_behavior.actions.get_by_name("double")
# 	if previous_action.legs_animator == double_action.legs_animator: # ie both are simple of AnimatorModifier
# 		double_action.legs_animator.play(current_action.animation, 0.15)
# 	else:
# 		double_action.legs_animator.play(current_action.animation, 0)
# 		double_action.legs_anim_settings.play("simple", 0.15)

# func tracks_input_vector() -> bool:
# 	return current_action.acts_between(0.2, 0.4) and current_action.action_name == "release"
