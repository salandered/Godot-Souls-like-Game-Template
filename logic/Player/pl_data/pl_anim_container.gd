extends RefCounted
class_name PlAnimList


var list_of_animations: Array[AnimationData] = [
	## loco
	AnimationData.new(A.move.idle),
	AnimationData.new(A.move.idle_to_sprint, 1.3),
	AnimationData.new(A.move.sprint_to_idle, 0.85),
	AnimationData.new(A.move.run),
	AnimationData.new(A.move.sprint),
	AnimationData.new(A.move.turn_180_R, 1.2, true),
	AnimationData.new(A.move.turn_180_L, 1.2, true),
	AnimationData.new(A.move.fast_turn_180_R, 1.0, true),
	AnimationData.new(A.move.fast_turn_180_L, 1.0, true),
	# loco strafe
	# AnimationData.new(A.combat_walk_f, 1.1),
	# AnimationData.new(A.combat_walk_b, 1.1),
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

	# air
	AnimationData.new(A.air.midair),
	AnimationData.new(A.air.jump_sprint, 0.8),
	AnimationData.new(A.air.landing_sprint, 0.9),
	AnimationData.new(A.air.jump_idle),


	#
	AnimationData.new(A.roll),
	#
	AnimationData.new(A.death),

	## attacks
	AnimationData.new(A.attack.axe_slice_1),
	AnimationData.new(A.attack.axe_slice_2, 0.85),
	AnimationData.new(A.attack.attack_from_run),
	
	AnimationData.new(A.attack.sword_slash_1),
	AnimationData.new(A.attack.sword_slash_2),
	
	## fight
	AnimationData.new(A.combat.hit_reaction),
	AnimationData.new(A.combat.staggered),
	AnimationData.new(A.combat.parry),
	AnimationData.new(A.combat.parried),
	AnimationData.new(A.combat.riposte_attack),
	AnimationData.new(A.combat.idle_longsword),
]