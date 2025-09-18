extends BaseHSMEState


@export var combo_starters: Array[BaseHSMEState]

var ended: bool = false ## why?
var attacks_to_do: int


func check_transition(_delta) -> VerdictHSM:
	return VerdictHSM.new()


func choose_internal_state() -> VerdictHSM:
	return VerdictHSM.new(combo_starters.pick_random().state_name)


func update(_delta):
	if distance_to_player() > 8 and current_state.close_to_the_end_of_animation():
		ended = true


func on_enter():
	ended = false
	attacks_to_do = randi_range(2, 3)
	print_.hsme(state_name, str(attacks_to_do) + " attacks to do:", 2)
