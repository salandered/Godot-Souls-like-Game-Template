extends BaseAction
class_name PlayerAction


var player_sm: PlayerSM

# not abstract
func update(_input: InputPackage, _delta: float):
	pass


func animate(): # ▶️
	# if animation == "roll" or animation == "block":
		# print_.prefix("~~ SOS", "")
	print_.psm("▶️ Action " + action_name, anim.anim_id + " with blend time " + str(default_blend_time), 8)
	animator_manager.set_anim_to_play(anim.anim_id, default_blend_time)

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