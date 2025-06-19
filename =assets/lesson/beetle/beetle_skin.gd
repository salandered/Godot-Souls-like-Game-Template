extends MobSkin3D

## Emitted when the bettle's front legs hit the ground in the walk animation.
signal stepped

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@onready var _animation_player: AnimationPlayer = %AnimationPlayer


# NOTE: When using an animation tree, AnimationPlayer.animation_finished does not emit,
# and we don't have a signal to know when the state changed either,
# so we work around it by emitting a signal at the end of "one-shot" animations.
# A signal could also be emitted from a method call track in animations.
@onready var animation_lengths := {
	"stagger": _animation_player.get_animation("custom_animations/hurt").length,
	"die": _animation_player.get_animation("power_off").length
}

func play(animation_name: String) -> void:
	if animation_name == "idle":
		state_machine.travel("idle")
	elif animation_name in ["chase", "walk"]:
		state_machine.travel("walk")
	elif animation_name == "attack":
		animation_tree.set("parameters/AttackOneShot/request", true)
	elif animation_name == "stagger":
		state_machine.travel("idle")
		animation_tree.set("parameters/HurtOneShot/request", true)
		get_tree().create_timer(animation_lengths.stagger).timeout.connect(func ():
			animation_finished.emit("stagger")
		)
	elif animation_name == "die":
		state_machine.travel("power_off", true)
		get_tree().create_timer(animation_lengths.die + 0.5).timeout.connect(func ():
			animation_finished.emit("die")
		)
