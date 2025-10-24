extends BasePHState

@export_group("grab attack")
var min_grab_distance: float = 2
var max_grab_distance: float = 3
var grab_sector: float = 1 # radians
var grab_cooldown: float = 15
@export_group("gapclose attack")
var gap_close_distance: float = 8
@export_group("scare-off attack")
var max_scareoff_radius: float = 1.5
var back_sector: float = 1 # radians
@export_group("attack series")
@export var attack_series: BasePHState
@export var aggro_drop_radius: float = 5

func check_transition(_delta) -> VerdictPH:
	if conditioned_attack_ended() or attack_series_ended():
		return VerdictPH.new("chill_1")
	return VerdictPH.new()

# if we performed one of vscare-off, grab or gapclose attacks AND they just ended
func conditioned_attack_ended() -> bool:
	return ["scare_off", "grab", "gapclose"].has(current_lower_state.state_name) and current_lower_state.works_longer_than(current_lower_state.get_animation_length())

# if we performed a random series of attacks
func attack_series_ended():
	#print(str(attack_series.attacks_to_do) + " attacks to do")
	return attack_series.ended


func choose_internal_state() -> VerdictPH:
	#if can_grab_player():
		#return VerdictPH.new("grab")
	if player_too_far():
		return VerdictPH.new("gapclose")
	if player_too_close():
		return VerdictPH.new("scare_off")
	return VerdictPH.new("attack_series")


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
