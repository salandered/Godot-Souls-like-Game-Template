extends BaseHSMEState

@export var pursuit_radius: float = 8
@export var max_chill_time: float
@export var min_chill_time: float
var will_chill_for: float


func check_transition(_delta) -> VerdictHSM:
	if current_state.works_longer_than(will_chill_for) or _caught_up_with_player():
		return VerdictHSM.new("combat_1")
	return VerdictHSM.new()

func choose_internal_state() -> VerdictHSM:
	if distance_to_player() > pursuit_radius:
		return VerdictHSM.new("pursuit_1")
	return VerdictHSM.new("orbiting")

func _caught_up_with_player() -> bool:
	return current_state.state_name == "pursuit_1" and distance_to_player() < pursuit_radius


func on_enter():
	will_chill_for = randf_range(min_chill_time, max_chill_time)
