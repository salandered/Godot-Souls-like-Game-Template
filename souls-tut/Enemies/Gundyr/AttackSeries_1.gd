extends HFSM


var ended: bool = false
var attacks_to_do: int
@export var combo_starters: Array[HFSM]


func check_transition(_delta) -> TransitionData:
	return TransitionData.new(false, "")


func choose_internal_state() -> TransitionData:
	return TransitionData.new(true, combo_starters.pick_random().state_name)


func update(_delta):
	if distance_to_player() > 8 and current_state.close_to_the_end_of_animation():
		ended = true


func on_enter():
	ended = false
	attacks_to_do = randi_range(2, 3)
	print(str(attacks_to_do) + " attacks to do:")
