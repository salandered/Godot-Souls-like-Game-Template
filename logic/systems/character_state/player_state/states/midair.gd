extends BasePlayerState


func initialise() -> void:
	APPLY_GRAVITY = false

func check_transition(input_: InputPackage) -> PLVerdict:
	if area_awareness.floor_dist_under_landing_height():
		# var xz_velocity = get_player().velocity
		# xz_velocity.y = 0
		# if xz_velocity.length_squared() >= 10:
		# 	return PLVerdict.new(PS.landing_sprint) 
		__log_psm_check("floor_dist_under_landing_height => landing_sprint")
		return PLVerdict.new(PS.landing_sprint)
	
	return PLVerdict.new("")
