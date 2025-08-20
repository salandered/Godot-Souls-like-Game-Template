## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends BaseAction
class_name LegsAction


# var legs_anim_settings: AnimationPlayer
# @export var anim_settings: String = "simple"

var legs_sm: LegsSM
var motion_type: LegsSM.MotionType

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func update(_input: InputPackage, _delta: float):
	pass

## can be overriden (see double action)
func animate():
	print_.prefix("▶️ LSM Action ", "animation " + animation, 8)
	legs_sm.legs_animator.play(animation, 0.2)


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# todo: oh fuck what is this dependency
	return player.model.player_sm.velocity_by_input(input, delta)
