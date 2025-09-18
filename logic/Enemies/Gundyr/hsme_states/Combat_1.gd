extends BaseHSMEState

@export_group("grab attack")
@export var min_grab_distance: float = 2
@export var max_grab_distance: float = 3
@export var grab_sector: float = 1 # radians
@export var grab_cooldown: float = 15
@export_group("gapclose attack")
@export var gap_close_distance: float = 8
@export_group("scare-off attack")
@export var max_scareoff_radius: float = 1.5
@export var back_sector: float = 1 # radians
@export_group("attack series")
@export var attack_series: BaseHSMEState
@export var aggro_drop_radius: float = 5

func check_transition(_delta) -> VerdictHSM:
	if conditioned_attack_ended() or attack_series_ended():
		return VerdictHSM.new("chill_1")
	return VerdictHSM.new()

# if we performed one of scare-off, grab or gapclose attacks AND they just ended
func conditioned_attack_ended() -> bool:
	return ["scare_off", "grab", "gapclose"].has(current_state.state_name) and current_state.works_longer_than(current_state.get_animation_length())

# if we performed a random series of attacks
func attack_series_ended():
	#print(str(attack_series.attacks_to_do) + " attacks to do")
	return attack_series.ended


func choose_internal_state() -> VerdictHSM:
	#if can_grab_player():
		#return VerdictHSM.new("grab")
	if player_too_far():
		return VerdictHSM.new("gapclose")
	if player_too_close():
		return VerdictHSM.new("scare_off")
	return VerdictHSM.new("attack_series")


func can_grab_player() -> bool:
	if distance_to_player() > max_grab_distance:
		return false
	if distance_to_player() < min_grab_distance:
		return false
	if angle_to_player() > grab_sector / 2:
		return false
	return true

func player_too_far() -> bool:
	return distance_to_player() > gap_close_distance

func player_too_close() -> bool:
	if distance_to_player() > max_scareoff_radius:
		return false
	if angle_to_player() > 3.14 - back_sector / 2:
		return false
	return true


func on_exit():
	attack_series.ended = false
