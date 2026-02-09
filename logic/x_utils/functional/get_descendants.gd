extends RefCounted
class_name get_descendants


## TODO: make func names consistent (plural vs singular)

class Descendant:
	var node_: Node
	var depth: int
	func _init(node__: Node, depth_: int):
		self.node_ = node__
		self.depth = depth_


## INTERNAL
# region

## by default first level has a depth of 0.
static func _get_descendants_filtered_with_depth(node: Node, filter: Callable, _depth: int = -1) -> Array[Descendant]:
	if not is_instance_valid(node):
		return []
		
	var descendants: Array[Descendant] = []
	for child in node.get_children():
		if filter.call(child):
			descendants.append(Descendant.new(child, _depth + 1))
		descendants.append_array(_get_descendants_filtered_with_depth(child, filter, _depth + 1))
	return descendants


## only_one - true means return first node that fits the filter
static func _get_descendants_filtered(
		node: Node,
		filter: Callable,
		only_one: bool = false,
		one_level: bool = false,
		skip_subscenes: bool = false,
	) -> Array:
	if not is_instance_valid(node):
		return []
	var descendants := []
	for child in node.get_children():
		var is_scene_root := not child.scene_file_path.is_empty()
		if skip_subscenes and is_scene_root:
			continue

		if filter.call(child):
			if only_one:
				return [child]
			descendants.append(child)
		
		if not one_level:
			var found := _get_descendants_filtered(child, filter, only_one, one_level, skip_subscenes)
			if only_one and not found.is_empty():
				return found
			descendants.append_array(found)

	return descendants

#endregion


# region: built in nodes


static func rich_text_labels(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is RichTextLabel)
	return r


static func label_3d_one_or_null(node: Node) -> Label3D:
	var r := _get_descendants_filtered(node, func(n): return n is Label3D, true)
	if len(r) > 0 and r[0] is Label3D:
		return r[0]
	return null


static func buttons(node: Node) -> Array[Button]:
	var r := _get_descendants_filtered(node, func(n): return n is Button)
	return TypeCast.array_of_button(r)


static func world_environments(node: Node) -> Array[WorldEnvironment]:
	var r := _get_descendants_filtered(node, func(n): return n is WorldEnvironment)
	return TypeCast.array_of_world_environment(r)


static func fog_volumes(node: Node, visible_only: bool = false) -> Array[FogVolume]:
	var r := _get_descendants_filtered(node,
		func(n): \
			return n is FogVolume \
				and (not visible_only or n.visible == true)
		)
	return TypeCast.array_of_fog_volume(r)


static func directional_lights_3d(node: Node, visible_only: bool = false) -> Array[DirectionalLight3D]:
	var r := _get_descendants_filtered(node,
		func(n): \
			return n is DirectionalLight3D \
				and (not visible_only or n.visible == true)
		)
	return TypeCast.array_of_directional_light_3d(r)

static func markers_3d(node: Node) -> Array[Marker3D]:
	var r := _get_descendants_filtered(node, func(n): return n is Marker3D)
	return TypeCast.array_of_marker_3d(r)


static func rigid_bodies(node: Node) -> Array[RigidBody3D]:
	var r := _get_descendants_filtered(node, func(n): return n is RigidBody3D)
	return TypeCast.array_of_rigid_body_3d(r)

static func areas(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is Area3D)


static func collision_shapes(node: Node) -> Array[CollisionShape3D]:
	var r := _get_descendants_filtered(node, func(n): return n is CollisionShape3D)
	r = TypeCast.array_of_collision_shape(r)
	return r


static func static_bodies(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is StaticBody3D)


static func mesh_instances(node: Node, visible_only: bool = false) -> Array[MeshInstance3D]:
	var r := _get_descendants_filtered(
		node,
		func(n): \
			return n is MeshInstance3D \
				and (not visible_only or n.visible == true)
		)
	return TypeCast.array_of_mesh_instances(r)

static func mesh_instances_visible(node: Node, is_visible: bool = false, one_level: bool = false) -> Array:
	var filter := func(n):
		if n is MeshInstance3D:
			# why i needed that?
			return not is_visible or n.is_visible_in_tree()
		return false
	return _get_descendants_filtered(node, filter, one_level)


static func csg_primitives(node: Node) -> Array:
	var _r := _get_descendants_filtered(node, func(n): return n is CSGPrimitive3D)
	return TypeCast.array_of_csg_primitive(_r)


static func bone_attachments(node: Node) -> Array[BoneAttachment3D]:
	var _r := _get_descendants_filtered(node, func(n): return n is BoneAttachment3D)
	return TypeCast.array_of_bone_attachments(_r)


static func audio_stream_players_3D(node: Node, skip_subscenes: bool = false) -> Array[AudioStreamPlayer3D]:
	var r := _get_descendants_filtered(node, func(n): return n is AudioStreamPlayer3D, false, false, skip_subscenes)
	r = TypeCast.array_of_audio_stream_player_3d(r)
	return r

# endregion


# region: custom nodes


static func shake_buttons(node: Node) -> Array[ShakeButton]:
	var r := _get_descendants_filtered(node, func(n): return n is ShakeButton)
	return TypeCast.array_of_shake_button(r)


static func break_static_parents(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is BreakStaticParent)
	return r


static func breakable_areas(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BreakableArea)


static func char_hit_boxes(node: Node) -> Array[CharacterHitbox]:
	var r := _get_descendants_filtered(node, func(n): return n is CharacterHitbox)
	r = TypeCast.array_of_char_hit_box(r)
	return r


static func base_character_movement(node: Node, only_one: bool = true) -> Array[BaseCharacterMovement]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseCharacterMovement, only_one)
	return TypeCast.array_of_base_character_movement(r)
	
static func look_at_character_markers(node: Node, only_one: bool = true) -> Array[LookAtCharacterMarker]:
	var r := _get_descendants_filtered(node, func(n): return n is LookAtCharacterMarker, only_one)
	return TypeCast.array_of_look_at_character_marker(r)
	
static func look_at_head_modifiers(node: Node) -> Array[LookAtHeadModifier3D]:
	var r := _get_descendants_filtered(node, func(n): return n is LookAtHeadModifier3D)
	return TypeCast.array_of_look_at_head_modifier(r)
	
static func look_at_manager(node: Node, only_one: bool = true) -> Array[ELookAtManager]:
	var r := _get_descendants_filtered(node, func(n): return n is ELookAtManager, only_one)
	return TypeCast.array_of_look_at_mangers(r)

static func pl_look_at_manager(node: Node, only_one: bool = true) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is PlayerLookAtManager, only_one)
	return r

static func base_anim_managers(node: Node, only_one: bool = true) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAnimatorManager, only_one)
	return TypeCast.array_of_base_animator_manager(r)
	

static func base_combat(node: Node, only_one: bool = true) -> Array[BaseCombat]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseCombat, only_one)
	return TypeCast.array_of_base_combat(r)

static func base_area_awareness(node: Node, only_one: bool = true) -> Array[BaseAreaAwareness]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAreaAwareness, only_one)
	return TypeCast.array_of_base_area_awareness(r)


static func character_sfx_systems(node: Node, only_one: bool = true) -> Array[CharacterSFXSystem]:
	var r := _get_descendants_filtered(node, func(n): return n is CharacterSFXSystem, only_one)
	return TypeCast.array_of_character_sfx_system(r)


static func base_anim_params_containers(node: Node, only_one: bool = true) -> Array[BaseAnimParamsContainer]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAnimParamsContainer, only_one)
	return TypeCast.array_of_base_anim_params_container(r)

static func anim_container(node: Node, only_one: bool = true) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is AnimContainer, only_one)
	return r

static func dev_visualise_trail_weapon(node: Node, only_one: bool = false) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is DevVisualiseTrailWeapon, only_one)
	return r

static func dev_visualise_trail_weapon_one_or_null(node: Node) -> DevVisualiseTrailWeapon:
	var r := dev_visualise_trail_weapon(node, true)
	if len(r) > 0 and r[0] is DevVisualiseTrailWeapon:
		return r[0]
	return null

static func dev_visualise_trail_one_or_null(node: Node) -> DevVisualiseTrail:
	var r := _get_descendants_filtered(node, func(n): return n is DevVisualiseTrail, true)
	if len(r) > 0 and r[0] is DevVisualiseTrail:
		return r[0]
	return null

static func dev_visualise_char_hit_boxes_one_or_null(node: Node) -> DevVisualiseCharHitBoxes:
	var r := _get_descendants_filtered(node, func(n): return n is DevVisualiseCharHitBoxes, true)
	if len(r) > 0 and r[0] is DevVisualiseCharHitBoxes:
		return r[0]
	return null


static func base_weapons(node: Node) -> Array[BaseWeapon]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseWeapon)
	return TypeCast.array_of_base_weapon(r)


# region: player

static func player_states(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BasePlayerState)

static func player_actions(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is PlayerAction)

static func legs_behaviors(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is LegsBehavior)

static func legs_actions(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is LegsAction)

# endregion


static func combos_one_level(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is Combo_, false, true)


# 

static func base_ph_composite_states_with_depth(node: Node) -> Array[Descendant]:
	return _get_descendants_filtered_with_depth(node, func(n): return n is BasePHEComposite)

static func base_ph_leaf_states(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BasePHELeaf)

static func base_m_f_states(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BaseMechFighterState)


static func enemy_camera_targets(node: Node) -> Array[EnemyCameraTarget]:
	var r := _get_descendants_filtered(node, func(n): return n is EnemyCameraTarget)
	return TypeCast.array_of_enemy_camera_target(r)


static func enemy_characters(node: Node) -> Array[PHCharacter]:
	var r := _get_descendants_filtered(node, func(n): return n is PHCharacter)
	return TypeCast.array_of_enemy_character(r)

static func one_princess(node: Node) -> Princess:
	var r := _get_descendants_filtered(node, func(n): return n is Princess, true)
	if r and len(r) > 0 and r[0] is Princess:
		return r[0]
	return null


# UI

static func pause_menu_controller(node: Node) -> Array[M_PauseMenuController]:
	var r := _get_descendants_filtered(node, func(n): return n is M_PauseMenuController)
	return TypeCast.array_of_pause_menu_controller(r)


static func base_dv_setting_check_button(node: Node) -> Array[BaseDVSettingCheckButton]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseDVSettingCheckButton)
	return TypeCast.array_of_base_dv_setting_check_button(r)

static func dv_vc_spinbox(node: Node) -> Array[DVValueChangerSpinBox]:
	var r := _get_descendants_filtered(node, func(n): return n is DVValueChangerSpinBox)
	return TypeCast.array_of_dv_vc_spinbox(r)


static func dv_line_edit(node: Node) -> Array[DVLineEdit]:
	var r := _get_descendants_filtered(node, func(n): return n is DVLineEdit)
	return TypeCast.array_of_dv_line_edit(r)

# 

# endregion
