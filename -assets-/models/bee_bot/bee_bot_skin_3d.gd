class_name BeeBotSkin3D extends MobSkin3D

@onready var _timer: Timer = %SecondaryActionTimer

@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get(
	"parameters/StateMachine/playback"
)
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

# NOTE: When using an animation tree, AnimationPlayer.animation_finished does not emit,
# and we don't have a signal to know when the state changed either,
# so we work around it by emitting a signal at the end of "one-shot" animations.
# A signal could also be emitted from a method call track in animations.
@onready var animation_lengths := {
	"stagger": _animation_player.get_animation("custom_lib/hurt").length,
	"die": _animation_player.get_animation("power_off").length
}


func _ready() -> void:
	_timer.timeout.connect(func _on_timer_timeout():
			if _state_machine.get_current_node() != "Idle":
				return
			_state_machine.travel("HeadMovement")
			_timer.start(randf_range(3.0, 8.0))
	)


func play(animation_name: String) -> void:
	if animation_name in [ "idle", "chase"]:
		_state_machine.travel("Idle", true)
		_timer.start()
	elif animation_name == "charge":
		_state_machine.travel("Attack")
	elif animation_name == "die":
		_state_machine.travel("PowerOff", true)
		_timer.stop()
		get_tree().create_timer(animation_lengths.die).timeout.connect(func ():
			animation_finished.emit("die")
		)
	elif animation_name == "stagger":
		_animation_tree.set("parameters/HurtShot/request", true)
		get_tree().create_timer(animation_lengths.stagger).timeout.connect(func ():
			animation_finished.emit("stagger")
		)
