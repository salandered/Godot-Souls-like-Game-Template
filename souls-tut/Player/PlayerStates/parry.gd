extends BasePlayerState


const PARRY_WINDOW_START : float = 0.2
const PARRY_WINDOW_END : float = 1


func react_on_hit(hit: HitData):
	# overrides the on_hit method to consult its parrying windows 
	# 	and if triggered, returns the call to the sender (current_state).
	if works_between(PARRY_WINDOW_START, PARRY_WINDOW_END) and hit.is_parryable:
		hit.weapon.holder.current_state.react_on_parry(hit)
		print("parry triggered")
	else:
		super.react_on_hit(hit)
	# delete hit package to avoid memory leaks
	hit.queue_free()
