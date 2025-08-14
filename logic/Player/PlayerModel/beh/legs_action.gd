# ## Legs_behaviours states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behaviour. 
# extends Node
# class_name LegsAction

# var player : KajinPlayer
# var camera : PlayerCamera
# var combat : KajCombat
# var legs : Legs
# var legs_anim_settings : AnimationPlayer

# @export var action_name : String
# @export var anim_settings : String = "simple"
# @export var legs_animator : SkeletonModifier3D
extends Node
# @export var motion_type : Legs.MotionType

# var enter_action_time : float

# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# var last_y_velocity : float

# func update(_input : InputPackage, _delta : float):
# 	pass

# # heirs use different animation modifiers, so we need per child definitions
# func setup_animator(_previous_action : LegsAction, _input : InputPackage):
# 	pass

# func _on_enter_action(input : InputPackage):
# 	mark_enter_action()
# 	on_enter_action(input)

# func on_enter_action(_input : InputPackage):
# 	pass

# func on_exit_action():
# 	pass
