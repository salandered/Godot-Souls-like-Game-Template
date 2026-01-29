extends PHEBaseNodeStateDataContainer
class_name SitSKNodeStateDataContainer


func get_node_to_composite_state_data() -> Dictionary[String, EDC._CSData]:
	return node_to_composite_state_data
func get_node_to_leaf_state_data() -> Dictionary[String, EDC._LStData]:
	return node_to_leaf_state_data


var node_to_composite_state_data: Dictionary[String, EDC._CSData] = {
	"_Top": EDC._CSData.new(SITSKS._TOP, EDC._CommitData.new(-1, -1)),
	"Life": EDC._CSData.new(SITSKS.life, EDC._CommitData.new(-1, -1)),

	"StillLifePhase": EDC._CSData.new(SITSKS.still_life_phase, EDC._CommitData.new(-1, -1)),
	"CombatPhase": EDC._CSData.new(SITSKS.combat_phase, EDC._CommitData.new(-1, -1)),
	"DeathPhase": EDC._CSData.new(SITSKS.death_phase, EDC._CommitData.new(-1, -1)),
}


var node_to_leaf_state_data: Dictionary[String, EDC._LStData] = {
	## idle
	"SitIdleV1": EDC._LStData.new(SITSKS.Leaf.sit_idle_v1, EDC._AData.new(SITSKA.idle_v1), EDC._CommitData.new(-1, -1)),
	"SitIdleV2": EDC._LStData.new(SITSKS.Leaf.sit_idle_v2, EDC._AData.new(SITSKA.idle_v2, -0.02), EDC._CommitData.new(-1, -1)),
	"SitTalking": EDC._LStData.new(SITSKS.Leaf.sit_talking, EDC._AData.new(SITSKA.talking), EDC._CommitData.new(-1, -1)),
	"SitIntimidate": EDC._LStData.new(SITSKS.Leaf.sit_intimidate, EDC._AData.new(SITSKA.intimidate, -0.05), EDC._CommitData.new(-1, -1)),
	"SitRubbing": EDC._LStData.new(SITSKS.Leaf.sit_rubbing, EDC._AData.new(SITSKA.rubbing, -0.05), EDC._CommitData.new(-1, -1)),
	
	## one time
	"SitPoint": EDC._LStData.new(SITSKS.Leaf.sit_point, EDC._AData.new(SITSKA.point), EDC._CommitData.new(-1, -1)),
	"SitClap": EDC._LStData.new(SITSKS.Leaf.sit_clap, EDC._AData.new(SITSKA.clap, -0.03), EDC._CommitData.new(-1, -1)),
	"SitDisbelief": EDC._LStData.new(SITSKS.Leaf.sit_disbelief, EDC._AData.new(SITSKA.disbelief_light), EDC._CommitData.new(-1, -1)),
	"SitLaugh": EDC._LStData.new(SITSKS.Leaf.sit_laugh, EDC._AData.new(SITSKA.laugh_light), EDC._CommitData.new(-1, -1)),
	
	## other
	"SitAttack": EDC._LStData.new(SITSKS.Leaf.sit_attack, EDC._AData.new(SITSKA.sit_attack), EDC._CommitData.new(-1, -1)),
	"Death": EDC._LStData.new(SITSKS.Leaf.death, EDC._AData.new(SITSKA.death)),

}
