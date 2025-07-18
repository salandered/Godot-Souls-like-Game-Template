extends LimboState


const WENT_IDLE := &"WENT_IDLE"
@onready var anim_tree = %AnimationTree

func _enter() -> void:
	var npc := agent
	print("|| NPC entered ", name)
	
	npc.hurt_cool_down.start(10)
	npc.remove_from_group(npc.group_name)
	# TODO: ragdoll variant
	# region: RAGDOLL cat
	# if ragdoll_death:
	# 	apply_ragdoll() ->
	# 	general_skeleton.physical_bones_start_simulation()
	# 	anim_tree.active = false
		
	# 	# if you want to stop the rag doll after a few seconds, uncomment this code.
	# 	await get_tree().create_timer(3).timeout
	# 	var bone_transforms = []
	# 	var bone_count = general_skeleton.get_bone_count()
	# 	for i in bone_count:
	# 		bone_transforms.append(general_skeleton.get_bone_global_pose(i))
	# 	general_skeleton.physical_bones_stop_simulation()
	# 	for i in bone_count:
	# 		general_skeleton.set_bone_global_pose_override(i, bone_transforms[i], 1, true)
	# endregion
	# death_started.emit()
	anim_tree.die()
	await get_tree().create_timer(4).timeout
	npc.queue_free()

func _update(_delta: float) -> void:
	var npc := agent
	
	npc.apply_gravity(_delta)
	anim_tree.set_movement()

	npc.move_and_slide()
