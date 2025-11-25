#@tool
#@icon("res://-assets-/x_icons/red/icon_skull.png")

@abstract
class_name BaseEnemyCharacter
extends BaseCharacter

@export_group("Player")
@export var player: Princess

#
var camera_target: EnemyCameraTarget


func initialise() -> void:
	var targets := get_descendants.enemy_camera_targets(self)
	for t: EnemyCameraTarget in targets:
		t.initialise(self)
		t.make_active()
	assert(len(targets) == 1, pp.s("support exactly one cam target for an enemy, got", len(targets)))
	camera_target = targets[0]