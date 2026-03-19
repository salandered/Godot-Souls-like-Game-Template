extends RefCounted
class_name ERequiredMarkers


static var anim_to_required_marker: Dictionary[StringName, Array] = {

	## 
	PHEA.sleep: [],
	PHEA.awaken: [],
	PHEA.death: [MarkerName.DEATH_SCATTER],
	PHEA.phase_switch: [MarkerName.PUSH_ITEMS_AROUND],
	PHEA.phase_switch_loop: [],


	## loco 
	PHEA.loco.combat_idle: [],
	PHEA.loco.combat_idle_stupid: [],
	PHEA.loco.walk_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.combat_walk_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.run_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.combat_run_forward: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.loco.jump_towards: [MarkerName.JUMP.LAND_START, MarkerName.JUMP.LAND_START, MarkerName.PUSH_ITEMS_AROUND],

	## strafe
	PHEA.strafe.strafe_right: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	PHEA.strafe.strafe_left: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],

	## dodge
	PHEA.dodge.dodge_R: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_L: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_F: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	PHEA.dodge.dodge_B: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],


	## attack
	PHEA.attack.scare_off: [MarkerName.PUSH_ITEMS_AROUND, MarkerName.ALLOWS_SWITCH],
	PHEA.attack.power_gap_closer: [MarkerName.JUMP.LAUNCH, MarkerName.JUMP.LAND_START, MarkerName.PUSH_ITEMS_AROUND],
	
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
	PHEA.react.react_from_L: [],
	PHEA.react.react_from_R: [],
	PHEA.react.react_gut: [],
	PHEA.react.body_impact: [],

	## pushback
	PHEA.react.react_dodge_B: [MarkerName.ALLOWS_SWITCH],
	PHEA.react.pushback_2: [MarkerName.ALLOWS_SWITCH],


}
