extends RefCounted
class_name get_descendants


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
		one_level: bool = false,
		skip_subscenes: bool = false,
		only_one: bool = false
	) -> Array:
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
			descendants.append_array(_get_descendants_filtered(child, filter, one_level))
	return descendants

#endregion


# region: built in nodes


static func rich_text_labels(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is RichTextLabel)
	return r


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
	return _get_descendants_filtered(node, func(n): return n is CSGPrimitive3D)

static func bone_attachments(node: Node) -> Array:
	return _get_descendants_filtered(node, func(n): return n is BoneAttachment3D)


static func audio_stream_players_3D(node: Node, skip_subscenes: bool = false) -> Array[AudioStreamPlayer3D]:
	var r := _get_descendants_filtered(node, func(n): return n is AudioStreamPlayer3D, false, skip_subscenes)
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


static func base_character_movements(node: Node) -> Array[BaseCharacterMovement]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseCharacterMovement)
	return TypeCast.array_of_base_character_movement(r)
	
static func look_at_character_markers(node: Node) -> Array[LookAtCharacterMarker]:
	var r := _get_descendants_filtered(node, func(n): return n is LookAtCharacterMarker)
	return TypeCast.array_of_look_at_character_marker(r)
	
static func look_at_head_modifiers(node: Node) -> Array[LookAtHeadModifier3D]:
	var r := _get_descendants_filtered(node, func(n): return n is LookAtHeadModifier3D)
	return TypeCast.array_of_look_at_head_modifier(r)
	
static func look_at_managers(node: Node) -> Array[ELookAtManager]:
	var r := _get_descendants_filtered(node, func(n): return n is ELookAtManager)
	return TypeCast.array_of_look_at_mangers(r)

static func pl_look_at_managers(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is PlayerLookAtManager)
	return r

static func base_anim_managers(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAnimatorManager)
	return TypeCast.array_of_base_animator_manager(r)
	

static func base_combats(node: Node) -> Array[BaseCombat]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseCombat)
	return TypeCast.array_of_base_combat(r)

static func base_area_awareness(node: Node) -> Array[BaseAreaAwareness]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAreaAwareness)
	return TypeCast.array_of_base_area_awareness(r)


static func base_sfx_systems(node: Node) -> Array[BaseSFXSystem]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseSFXSystem)
	return TypeCast.array_of_base_sfx_system(r)

static func character_sfx_systems(node: Node) -> Array[CharacterSFXSystem]:
	var r := _get_descendants_filtered(node, func(n): return n is CharacterSFXSystem)
	return TypeCast.array_of_character_sfx_system(r)


static func base_anim_params_containers(node: Node) -> Array[BaseAnimParamsContainer]:
	var r := _get_descendants_filtered(node, func(n): return n is BaseAnimParamsContainer)
	return TypeCast.array_of_base_anim_params_container(r)

static func anim_containers(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is AnimContainer)
	return r

static func dev_visualise_trail_weapon(node: Node) -> Array:
	var r := _get_descendants_filtered(node, func(n): return n is DevVisualiseTrailWeapon)
	return r

static func dev_visualise_trail_weapon_one_or_null(node: Node) -> DevVisualiseTrailWeapon:
	var r := dev_visualise_trail_weapon(node)
	if len(r) > 0 and r[0] is DevVisualiseTrailWeapon:
		return r[0]
	return null

static func dev_visualise_char_hit_boxes_one_or_null(node: Node) -> DevVisualiseCharHitBoxes:
	var r := _get_descendants_filtered(node, func(n): return n is DevVisualiseCharHitBoxes)
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
	return _get_descendants_filtered(node, func(n): return n is Combo_, true)


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
	var r := _get_descendants_filtered(node, func(n): return n is Princess, false, false, true)
	if r and len(r) > 0 and r[0] is Princess:
		return r[0]
	return null


# UI

static func pause_menu_controller(node: Node) -> Array[M_PauseMenuController]:
	var r := _get_descendants_filtered(node, func(n): return n is M_PauseMenuController)
	return TypeCast.array_of_pause_menu_controller(r)


# 

# endregion
