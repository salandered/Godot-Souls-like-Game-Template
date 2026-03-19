extends BaseMechFighterState


const ANIM_L := MFA.idle_l
const ANIM_R := MFA.idle_r


## idle never ends
func is_ended() -> bool:
	return false


func on_enter_state() -> void:
	var selected_anim_id := ANIM_L
	match me.varm_position:
		me.VArmPos.LEFT:
			selected_anim_id = ANIM_L
		me.VArmPos.RIGHT:
			selected_anim_id = ANIM_R

	__log_ent("chose anim", selected_anim_id, "based on varm_position", me.varm_position)
	anim = me._anim_container.get_by_anim_id(selected_anim_id)
