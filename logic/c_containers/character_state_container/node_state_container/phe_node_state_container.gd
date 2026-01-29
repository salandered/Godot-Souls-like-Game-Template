extends PHEBaseNodeStateDataContainer
class_name PHENodeStateDataContainer


func get_node_to_composite_state_data() -> Dictionary[String, EDC._CSData]:
	return node_to_composite_state_data
func get_node_to_leaf_state_data() -> Dictionary[String, EDC._LStData]:
	return node_to_leaf_state_data


var node_to_composite_state_data: Dictionary[String, EDC._CSData] = {
	"_Top": EDC._CSData.new(PHES._TOP, EDC._CommitData.new(-1, -1)),
	"Life": EDC._CSData.new(PHES.life, EDC._CommitData.new(-1, -1)),

	"StillLifePhase": EDC._CSData.new(PHES.still_life_phase, EDC._CommitData.new(-1, -1)),
	"CombatPhase": EDC._CSData.new(PHES.combat_phase, EDC._CommitData.new(-1, -1)),
	"DeathPhase": EDC._CSData.new(PHES.death_phase, EDC._CommitData.new(-1, -1)),
	
	"CombatLoco": EDC._CSData.new(PHES.combat_loco, EDC._CommitData.new(-1, -1)),
	"CombatAttacking": EDC._CSData.new(PHES.combat_attacking),
	"AttackClubSeries": EDC._CSData.new(PHES.attack_club_series),
	"AttackPickSingle": EDC._CSData.new(PHES.attack_pick_single),
	"AttackFromDodgeB": EDC._CSData.new(PHES.attack_from_dodge_b),
	"AttackWithDodgeF": EDC._CSData.new(PHES.attack_with_dodge_f),
	"Attack360Series": EDC._CSData.new(PHES.attack_360_series),
	
	"DodgeBackSeries": EDC._CSData.new(PHES.dodge_back_series),
	"DodgePlayful": EDC._CSData.new(PHES.dodge_playful),
}


var node_to_leaf_state_data: Dictionary[String, EDC._LStData] = {
	## one time
	"Sleep": EDC._LStData.new(PHES.Leaf.sleep, EDC._AData.new(PHEA.sleep, -0.15), EDC._CommitData.new(-1, -1), ),
	"Awaken": EDC._LStData.new(PHES.Leaf.awaken, EDC._AData.new(PHEA.awaken, -0.15), ),
	"Death": EDC._LStData.new(PHES.Leaf.death, EDC._AData.new(PHEA.death)),
	"PhaseSwitch": EDC._LStData.new(PHES.Leaf.phase_switch, EDC._AData.new(PHEA.phase_switch, -0.3)),

	## loco
	"CombatIdle": EDC._LStData.new(PHES.Leaf.combat_idle, EDC._AData.new(PHEA.loco.combat_idle, -0.03), EDC._CommitData.new(0.4), ),
	"Pursue": EDC._LStData.new(PHES.Leaf.pursue, EDC._AData.new(PHEA.loco.run_forward, -0.06), EDC._CommitData.new(0.3, 30)),
	"Orbit": EDC._LStData.new(PHES.Leaf.orbit, EDC._AData.new(PHEA.strafe.strafe_right), EDC._CommitData.new(0.5)),
	"DodgeB": EDC._LStData.new(PHES.Leaf.dodge_B, EDC._AData.new(PHEA.dodge.dodge_B, -0.05)),
	"DodgeF": EDC._LStData.new(PHES.Leaf.dodge_F, EDC._AData.new(PHEA.dodge.dodge_F, -0.05)),
	"DodgeL": EDC._LStData.new(PHES.Leaf.dodge_L, EDC._AData.new(PHEA.dodge.dodge_L, -0.05)),
	"DodgeR": EDC._LStData.new(PHES.Leaf.dodge_R, EDC._AData.new(PHEA.dodge.dodge_R, -0.05)),
	"JumpTowards": EDC._LStData.new(PHES.Leaf.jump_towards, EDC._AData.new(PHEA.loco.jump_towards, -0.1)),
	"Midair": EDC._LStData.new(PHES.Leaf.midair, EDC._AData.new(PHEA.loco.midair, -0.0)),

	## attack
	"ScareOff": EDC._LStData.new(PHES.Leaf.scare_off, EDC._AData.new(PHEA.attack.scare_off, -0.25)),
	"GapCloser": EDC._LStData.new(PHES.Leaf.gap_closer, EDC._AData.new(PHEA.attack.power_gap_closer, -0.28)),
	"ClubPart1": EDC._LStData.new(PHES.Leaf.club_part_1, EDC._AData.new(PHEA.attack.club_part_1, -0.15)),
	"ClubPart2": EDC._LStData.new(PHES.Leaf.club_part_2, EDC._AData.new(PHEA.attack.club_part_2, -0.15)),
	"ClubPart3_4": EDC._LStData.new(PHES.Leaf.club_part_3_4, EDC._AData.new(PHEA.attack.club_part_3_4, -0.15)),
	"Attack360High": EDC._LStData.new(PHES.Leaf.attack_360_high, EDC._AData.new(PHEA.attack.attack_360_high, -0.15)),
	"Attack360Low": EDC._LStData.new(PHES.Leaf.attack_360_low, EDC._AData.new(PHEA.attack.attack_360_low, -0.15)),
	"AttackUp": EDC._LStData.new(PHES.Leaf.attack_up, EDC._AData.new(PHEA.attack.attack_up, -0.13)),
	"AttackDown": EDC._LStData.new(PHES.Leaf.attack_down, EDC._AData.new(PHEA.attack.attack_down, -0.15)),
	"SwordSlide": EDC._LStData.new(PHES.Leaf.sword_slide, EDC._AData.new(PHEA.attack.sword_slide, -0.25)),
	"PowerUp": EDC._LStData.new(PHES.Leaf.power_up, EDC._AData.new(PHEA.attack.power_up, -0.07)),
	"StabLow": EDC._LStData.new(PHES.Leaf.stab_low, EDC._AData.new(PHEA.attack.stab_low, -0.07)),
	
	## react
	"Pushback": EDC._LStData.new(PHES.Leaf.pushback, EDC._AData.new(PHEA.react.react_dodge_B, -0.1), EDC._CommitData.new(-1, -1)),
	"Pushback2": EDC._LStData.new(PHES.Leaf.pushback_2, EDC._AData.new(PHEA.react.pushback_2, -0.1), EDC._CommitData.new(-1, -1)),
}
