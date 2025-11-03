extends PlayerState


func on_enter_state(input_: InputPackage):
	get_player().add_to_group("parried_humanoid")


func on_exit_state() -> void:
	get_player().remove_from_group("parried_humanoid")
