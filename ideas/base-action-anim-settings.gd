extends RefCounted

# func animate():
	# ...
	# region: future reference
	# print_.prefix("SKM", "_base _animate with " + animator_set + " settings_switch_time " + str(settings_switch_time))
	# # animator_set - like "full_body" or "torso_legs"
	# if animation_settings.current_animation == animator_set:
	# 	# if pose-to-pose transition inside one modifier -> we use one blending mechanism
	# 	animator_manager.play(animation, animation_blend_time)
	# else:
	# 	# and if modifier-to-modifier transition -> we switch in modifier poses instantly. 
	# 	animator_manager.play(animation, 0)
	# # on enter state, settings_animator plays the needed settings template
	# # It's purple node =>  inside the frame, this thing executes before the first sk modifier
	# animation_settings.play(animator_set, settings_switch_time)
	# endregion