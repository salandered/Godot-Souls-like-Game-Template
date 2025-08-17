## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends ActionUtils
class_name LegsAction

var player: Princess
var combat: HumanoidCombat
var legs_sm: LegsSM
# var legs_anim_settings: AnimationPlayer

var action_name: String
var animation: String
# @export var anim_settings: String = "simple"
var motion_type: LegsSM.MotionType

var legs_animator: SimpleAnimator_

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0


# State
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_y_velocity: float = 0.0


func update(_input: InputPackage, _delta: float):
	pass

## can be overriden (see double action)
func animate(previous_action: LegsAction, _input: InputPackage):
	print_.prefix("~~ LSM Action PLAY", "animation " + animation, 2)
	legs_animator.play(animation, 0.2)

func _on_enter_action(input: InputPackage):
	mark_enter_action()
	on_enter_action(input)

func on_enter_action(_input: InputPackage):
	pass

func _on_exit_action():
	pass


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# todo: oh fuch what is this dependency
	return player.model.player_sm.velocity_by_input(input, delta)
