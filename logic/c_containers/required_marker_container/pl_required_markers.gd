extends RefCounted
class_name PlRequiredMarkers
## DOCS

## Several time i noticed that markers dissapear form the animation. 
## I can't trace down what goes wrong. 
## This is unacceptable for this project
## Using this at least we know on start up if something. it's a temporary measure.
## 'Required' means that SM won't work properly without anim having this marker.

static var anim_to_required_marker: Dictionary[String, Array] = {

	## one time
	# TODO: add deeath # A.death: [],

	## loco 
	A.loco.idle: [],
	A.loco.idle_to_sprint: [],
	A.loco.sprint_to_idle: [],
	A.loco.run: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	A.loco.sprint: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	A.loco.turn_180_L: [MarkerName.TURN_180_APEX],
	A.loco.turn_180_R: [MarkerName.TURN_180_APEX],
	A.loco.fast_turn_180_L: [MarkerName.TURN_180_APEX],
	A.loco.fast_turn_180_R: [MarkerName.TURN_180_APEX],

	## strafe
	A.strafe.combat_run_f: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	A.strafe.combat_run_b: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	A.strafe.strafe_L: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],
	A.strafe.strafe_R: [MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT],

	## dodge
	A.dodge.dodge_R: [MarkerName.FROM_RUN, MarkerName.TO_RUN, MarkerName.ALLOWS_SWITCH_TO_ATTACK],
	A.dodge.dodge_L: [MarkerName.FROM_RUN, MarkerName.TO_RUN, MarkerName.ALLOWS_SWITCH_TO_ATTACK],
	A.dodge.dodge_F: [MarkerName.FROM_RUN, MarkerName.TO_RUN, MarkerName.ALLOWS_SWITCH_TO_ATTACK],
	A.dodge.dodge_B: [MarkerName.FROM_RUN, MarkerName.TO_RUN, MarkerName.ALLOWS_SWITCH_TO_ATTACK],
	A.dodge.dodge_R_head: [MarkerName.OVERLAY.START, MarkerName.OVERLAY.END],
	A.dodge.dodge_L_head: [MarkerName.OVERLAY.START, MarkerName.OVERLAY.END],


	## air 
	A.air.midair: [],
	A.air.jump_sprint: [MarkerName.JUMP.LAUNCH, MarkerName.JUMP.PEAK, MarkerName.JUMP.START_END],
	A.air.landing_sprint: [MarkerName.JUMP.LAND_START, MarkerName.JUMP.LEG_CONTACT, MarkerName.JUMP.RUN_AGAIN],


	## attack
	A.attack.axe_slice_1: [MarkerName.ALLOWS_SWITCH, MarkerName.ALLOWS_SWITCH_TO_ITSELF],
	A.attack.axe_slice_2: [MarkerName.ALLOWS_SWITCH],
	A.attack.axe_slice_3: [MarkerName.ALLOWS_SWITCH],
	A.attack.sword_slash_1: [MarkerName.ALLOWS_SWITCH, MarkerName.ALLOWS_SWITCH_TO_ITSELF],
	A.attack.sword_slash_2: [MarkerName.ALLOWS_SWITCH],
	A.attack.sword_slash_3: [MarkerName.ALLOWS_SWITCH],
	A.attack.stab_attack_1: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH, MarkerName.TO_IDLE],
	A.attack.stab_attack_2: [MarkerName.FROM_DODGE, MarkerName.ALLOWS_SWITCH, MarkerName.TO_IDLE],


	## react 
	A.react.head_B_large: [],
	A.react.react_from_R: [],
	A.react.react_from_L: [],
	A.react.react_gut: [],
	A.react.hit_push_b_rm: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],
	A.react.react_dodge_B: [MarkerName.FROM_RUN, MarkerName.ALLOWS_SWITCH],

	## fall stand up
	A.fall_stand_up.thrown_r_rm: [MarkerName.FROM_RUN, MarkerName.JUMP.LAND_START, MarkerName.TO_RUN],
	A.fall_stand_up.thrown_l_rm: [MarkerName.FROM_RUN, MarkerName.JUMP.LAND_START, MarkerName.TO_RUN],
	A.fall_stand_up.thrown_r_small_rm: [MarkerName.FROM_RUN, MarkerName.JUMP.LAND_START, MarkerName.TO_RUN],
	A.fall_stand_up.thrown_l_small_rm: [MarkerName.FROM_RUN, MarkerName.JUMP.LAND_START, MarkerName.TO_RUN],

}
