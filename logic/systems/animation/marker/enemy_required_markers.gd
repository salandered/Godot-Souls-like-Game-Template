extends RefCounted
class_name ERequiredMarkers


static var anim_to_required_marker: Dictionary[String, Array] = {
	## loco 
	PHEA.loco.walk_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.combat_walk_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.run_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.combat_run_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.jump_towards: [MarkerName.JUMP.LAND_START, MarkerName.JUMP.LAND_START],

	## strafe
	PHEA.strafe.strafe_right: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.strafe.strafe_left: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],

	## dodge
	PHEA.dodge.dodge_R: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_L: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_F: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_B: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],


	## attack
	# PHEA.attack.scare_off: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.power_gap_closer: [MarkerName.JUMP.LAUNCH, MarkerName.JUMP.LAND_START],
	PHEA.attack.attack_360_high: [MarkerName.ALLOWS_SWITCH, MarkerName.EARLY_SERIES_SWITCH],
	PHEA.attack.attack_360_low: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.attack_up: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.attack_down: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.club_part_1: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.club_part_2: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.club_part_3_4: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.sword_slide: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.power_up: [MarkerName.ALLOWS_SWITCH],
	PHEA.attack.stab_low: [MarkerName.ALLOWS_SWITCH],


	## react 


	## fall stand up


}
