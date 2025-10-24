extends BasePHState


@export var combo_starters: Array[BasePHState]

var ended: bool = false ## why?
var attacks_to_do: int


func check_transition(_delta) -> VerdictPH:
	return VerdictPH.new()


func choose_internal_state() -> VerdictPH:
	return VerdictPH.new(combo_starters.pick_random().state_name)


func update(_delta):
	if distance_to_player() > 8 and current_lower_state.close_to_the_end_of_animation():
		ended = true


func on_enter():
	ended = false
	attacks_to_do = randi_range(2, 3)
	print_.phe_sm(state_name, str(attacks_to_do) + " attacks to do:", 2)
