## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends BaseAction
class_name LegsAction

var legs_sm: LegsSM

var motion_type: LegsSM.MotionType

var SPEED: float = 3.0
var TURN_SPEED: float = 2.0
var SPEED_SCALE: float = 1.0


## Not abstract! It can be empty and not overriden. (double action)
func update(_input: InputPackage, _delta: float):
	pass


## can be overriden (see double action)
func animate(): # ▶️
	print_.lsm_action(action_name + em.play, "animation " + anim_name, 8)
	
	# 🚧
	legs_sm.full_body_animator.set_anim_to_play(anim_name, 0.2)


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# todo: oh fuck what is this dependency
	return player.model.player_sm.__velocity_by_input(input, delta)
