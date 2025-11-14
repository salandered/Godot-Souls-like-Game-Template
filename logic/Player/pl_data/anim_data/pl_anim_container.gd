extends RefCounted
class_name PlAnimList


var list_of_animations: Array[AnimationData] = [
	## loco
	AnimationData.new(A.loco.idle),
	AnimationData.new(A.loco.idle_to_sprint, 1.3),
	AnimationData.new(A.loco.sprint_to_idle, 0.85),
	AnimationData.new(A.loco.run),
	AnimationData.new(A.loco.sprint),
	AnimationData.new(A.loco.turn_180_R, 1.2, true),
	AnimationData.new(A.loco.turn_180_L, 1.2, true),
	AnimationData.new(A.loco.fast_turn_180_R, 1.0, true),
	AnimationData.new(A.loco.fast_turn_180_L, 1.0, true),

	## strafe
	AnimationData.new(A.strafe.combat_run_f, 1.0),
	AnimationData.new(A.strafe.combat_run_b, 1.0),
	AnimationData.new(A.strafe.strafe_R, 0.8),
	AnimationData.new(A.strafe.strafe_L, 0.8),

	## dodge
	AnimationData.new(A.dodge.dodge_R),
	AnimationData.new(A.dodge.dodge_L),
	AnimationData.new(A.dodge.dodge_F),
	AnimationData.new(A.dodge.dodge_B),
	AnimationData.new(A.dodge.dodge_R_head),
	AnimationData.new(A.dodge.dodge_L_head),

	## air
	AnimationData.new(A.air.midair),
	AnimationData.new(A.air.jump_sprint, 0.8),
	AnimationData.new(A.air.landing_sprint, 0.9),

	## react
	AnimationData.new(A.react.hit_reaction),
	AnimationData.new(A.react.head_B_large),
	AnimationData.new(A.react.react_from_R),
	AnimationData.new(A.react.react_from_L),
	AnimationData.new(A.react.react_gut),
	AnimationData.new(A.react.dodge_F_hit),
	AnimationData.new(A.react.hit_B_large_rm),
	AnimationData.new(A.react.hit_push_b_rm, 0.9),
	AnimationData.new(A.react.react_dodge_B, 0.85),

	## attacks
	AnimationData.new(A.attack.axe_slice_1),
	AnimationData.new(A.attack.axe_slice_2, 0.85),
	AnimationData.new(A.attack.attack_from_run, 1.2),
	AnimationData.new(A.attack.attack_from_dodge, 1.2),
	
	AnimationData.new(A.attack.sword_slash_1, 1.2),
	AnimationData.new(A.attack.sword_slash_2, 1.2),

	## one time
	AnimationData.new(A.death),

	## fall/stand up
	AnimationData.new(A.fall_stand_up.thrown_l_rm, 1.0),
	AnimationData.new(A.fall_stand_up.thrown_r_rm, 1.0),
	AnimationData.new(A.fall_stand_up.thrown_r_rm, 1.0),
	AnimationData.new(A.fall_stand_up.thrown_r_small_rm, 1.0),
	AnimationData.new(A.fall_stand_up.thrown_l_small_rm, 1.0),

]
