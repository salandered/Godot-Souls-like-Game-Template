@tool
@icon("res://-assets-/x_icons/char/image (23).png")
class_name BigGuyCharacter
extends PHCharacter


@export var fire_up: bool = false
@export var dev_tag: String = ""

@onready var _visuals_root: Node3D = $"VisualOffset/Visuals/gold parts v2"

@onready var pinga_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %PingaAnimSFXSigEmitter
@onready var aura_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %AuraAnimSFXSigEmitter
@onready var fire_marker: Marker3D = %fire_marker


const FLICKER_FIRE = preload("uid://bnf3bmp3nq5nq")


func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]:
	return {
			WeaponID.big_pinga_blade: pinga_anim_sfx_sig_emitter,
			WeaponID.bg_aura_weapon: aura_anim_sfx_sig_emitter
		}
func _for_init_anim_list() -> BaseCharAnimList:
	return PHEA.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return ERequiredMarkers.anim_to_required_marker
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.big_pinga_blade, WeaponID.bg_aura_weapon]


##

func initialise_phe_char_implementation():
	add_to_group(Groups.Chars.BIG_GUY)

	SigUtils.safe_connect(SIG_land_wave, _on_sig_land_wave)
	

func get_initial_leaf_state_name() -> String:
	return PHES.Leaf.sleep


func get_visuals_root() -> Node3D:
	return _visuals_root


func get_node_state_container() -> PHEBaseNodeStateDataContainer:
	return PHENodeStateDataContainer.new()


func set_angry_raised():
	angry_raised = true
	SigUtils.safe_emit_raw_no_payload(SIG_angry_raised)
	if fire_up:
		apply_fire_to_head()


func _on_death_raised_implementation() -> void:
	await FrameUtils.wait_process_frames(2)
	
	print_.prefix("_trigger_death_scatter()")
	if head_off:
		await _trigger_death_scatter(visuals)

	if fire_up:
		remove_fire_effect()

	var sig_data := get_sig_container().get_by_sig_id(SignalID.sfx_unique)
	SigUtils.safe_emit(sig_data, {SFXConstants.unique_key: SFXConstants.Unique.accomplish})


const RIGID_SHATTER_SCRIPT = preload("uid://cvdt0we2m7pch")


func _trigger_death_scatter(mesh_list: Array[MeshInstance3D]):
	print_.prefix_s("glob position of an enemy", self.global_position)
	var rigids_container := Node3D.new()
	rigids_container.name = "EnemyDebrisContainer"
	get_tree().current_scene.add_child(rigids_container)

	rigids_container.global_position = self.global_position
	
	for visual_mesh: MeshInstance3D in mesh_list:
		if not visual_mesh.mesh:
			continue
		await FrameUtils.wait_one_physics_frame()
		var physics_config := RigidPhysicsConfig.new(3.0, 1.5, 0.0, 2.5)
		var rigid_body := RigidBodyUtils.create_rigid_body_from_mesh_instance(visual_mesh, physics_config, true)
		if rigid_body:
			rigids_container.add_child(rigid_body)
			rigid_body.global_transform = visual_mesh.global_transform
			rigid_body.set_script(RIGID_SHATTER_SCRIPT)
			rigid_body._ready()
			var backward := -self.transform.basis.z
			var direction := (Vector3.UP * 0.94 + backward * 0.44).normalized()
			var impulse_strength := randf_range(8.0, 9.0)
			rigid_body.apply_central_impulse(direction * impulse_strength)
	
	for visual_mesh: MeshInstance3D in mesh_list:
		visual_mesh.visible = false
	print_.prefix("end of _trigger_death_scatter")


##


func apply_fire_to_head():
	if not FLICKER_FIRE or not fire_marker:
		return
	var fire_scene := FLICKER_FIRE.instantiate()
	var casted: FireStatic = fire_scene
	fire_marker.add_child(casted)
	casted.play_animation = false
	casted.play_move_animation = false
	casted.energy = 2.8
	casted.add_mist = false
	# fire.position = Vector3.ZERO  # Centered on marker

func remove_fire_effect():
	if not fire_marker:
		return
	for child in fire_marker.get_children():
		child.queue_free()

##

func get_run_state_names() -> Array[String]:
	return [PHES.Leaf.orbit]

func get_dodge_state_names() -> Array[String]:
	return [PHES.Leaf.dodge_F, PHES.Leaf.dodge_B, PHES.Leaf.dodge_L, PHES.Leaf.dodge_R]

func get_sprint_state_names() -> Array[String]:
	return [PHES.Leaf.pursue]

func get_idle_state_names() -> Array[String]:
	return [PHES.Leaf.combat_idle]


func get_power_attacks_state_names() -> Array[String]:
	return [
		PHES.Leaf.scare_off,
		PHES.Leaf.gap_closer,
		PHES.Leaf.sword_slide,
		PHES.Leaf.power_up,
		PHES.Leaf.attack_360_low,
		PHES.Leaf.phase_switch,
	   ]

##

# func _hard_death():
# 	await FrameUtils.wait_process_frames(5)
# 	self.queue_free()


func _on_monitor_player_enter_signal_area_sig_player_entered(incoming_body: Node3D) -> void:
	set_physics_process(true)


## DEV


# func _input(event: InputEvent) -> void:
# 	if not OS.is_debug_build():
# 		return
# 	var bone_mask := BoneMask.get_upper_body()
	# if event.is_action_pressed(RawAction.DEV_8):
	# 	animator_manager.set_overlay_anim(PHEA.react.react_from_R,
	# 	OverlayConfig.new(
	# 		OverlayConfig.Weight.new(0.5),
	# 		BlendConfig.new(0.12, 0.18),
	# 		1.0,
	# 		bone_mask
	# 		))
	# if event.is_action_pressed(RawAction.DEV_9):
	# 	animator_manager.set_overlay_anim(PHEA.react.react_from_R,
	# 	OverlayConfig.new(
	# 		OverlayConfig.Weight.new(1.0),
	# 		BlendConfig.new(0.2, 0.2),
	# 		1.0,
	# 		bone_mask
	# 	))
