extends RefCounted
class_name ReactUtils


class ReactionConfig:
	var anim_id: String
	var overlay_weight: float
	var bone_mask: Array[int]

	func _init(anim_id_: String, overlay_weight_: float, bone_mask_: Array[int]) -> void:
		self.anim_id = anim_id_
		self.overlay_weight = overlay_weight_
		self.bone_mask = bone_mask_
	
	func _to_string() -> String:
		var first_b = bone_mask[0] if bone_mask.size() > 0 else -1
		var last_b = bone_mask[-1] if bone_mask.size() > 0 else -1
		return "anim_id: %s, wght: %.2f, boneMsk [%d-%d] (size %d)" % [anim_id, overlay_weight, first_b, last_b, bone_mask.size()]


## only actions. If not mentioned - will be default values
static var player_muted_action = [PS.Act.death, PS.Act.double, Leg.Act.double]

## only leafes. If not mentioned - will be default values
static var enemy_muted_states = [PHES.Leaf.death, PHES.Leaf.phase_switch] # PHES.Leaf.sleep] dev


## nullable
static func calculate_reaction_for_player(hit: HitData, curr_action: String) -> ReactionConfig:
	if curr_action in player_muted_action:
		return null
	var overlay_weight: float
	if hit.damage < 1.0:
		overlay_weight = 0.0
	else:
		overlay_weight = _pick_overlay_weight(hit, Constants.ENEMY_MAX_HIT_DAMAGE)
	
	var anim_id_: String
	anim_id_ = _pick_react_anim_for_player(hit)

	var bone_mask = _pick_bone_mask_for_player(hit, curr_action)
	
	var react_cfg = ReactionConfig.new(anim_id_, overlay_weight, bone_mask)
	return react_cfg


## nullable
static func calculate_reaction_for_enemy(hit: HitData, curr_leaf_state: String) -> ReactionConfig:
	if curr_leaf_state in enemy_muted_states:
		return null
	var overlay_weight: float
	if hit.damage < 1.0:
		overlay_weight = 0.0
	else:
		overlay_weight = _pick_overlay_weight(hit, Constants.PLAYER_MAX_HIT_DAMAGE)
	
	var anim_id_: String
	anim_id_ = _pick_react_anim_for_enemy(hit)

	var bone_mask = _pick_bone_mask_for_enemy(hit, curr_leaf_state)
	
	var react_cfg = ReactionConfig.new(anim_id_, overlay_weight, bone_mask)
	return react_cfg


## PICK REACT ANIM
# region

## todo: some smart system which detects, where we collided ...
static var pl_attack_to_enemy_react = {
	A.attack.axe_slice_1: PHEA.react.body_impact,
	A.attack.axe_slice_2: PHEA.react.react_gut,
	A.attack.attack_from_run: PHEA.react.react_gut,
	A.attack.attack_from_dodge: PHEA.react.body_impact,
	A.attack.sword_slash_1: PHEA.react.react_from_R,
	A.attack.sword_slash_2: PHEA.react.react_from_L,
	}

static var enemy_attack_to_pl_react = {
	PHEA.attack.attack_360_high: A.react.from_R,
	PHEA.attack.attack_360_low: A.react.from_R,
	PHEA.attack.attack_down: A.react.react_gut,
	PHEA.attack.attack_up: A.react.head_B_large,
	PHEA.attack.club_part_1: A.react.from_L,
	PHEA.attack.club_part_2: A.react.from_R,
	PHEA.attack.club_part_3_4: A.react.from_L,
	PHEA.attack.power_gap_closer: A.react.react_gut,
	PHEA.attack.gap_closer: A.react.hit_B_large_rm,
	PHEA.attack.sword_slide: A.react.react_gut,
	PHEA.attack.scare_off: A.react.hit_B_large_rm,
	}


static func _pick_react_anim_for_enemy(hit: HitData) -> String:
	var _anim_id
	_anim_id = u.safe_get_dict_key(pl_attack_to_enemy_react, hit.anim_id, PHEA.react.react_from_R)
	return _anim_id


static func _pick_react_anim_for_player(hit: HitData) -> String:
	var _anim_id
	_anim_id = u.safe_get_dict_key(enemy_attack_to_pl_react, hit.anim_id, A.react.from_R)
	return _anim_id

# endregion


static func _pick_overlay_weight(hit: HitData, max_damage: float) -> float:
	var linear_value = hit.damage / max_damage
	var clamped_linear = clampf(linear_value, 0.0, 1.0)

	# [10, 35] (max 35) -> [0.54, 1.0]
	# [10, 15] (max 15) -> [0.82, 1.0]
	var eased_value = ease(clamped_linear, 0.5) # ease out
	return eased_value


## PICK BONE MASK
# region


## if not mentioned - will be default
static var enemy_state_to_bone_mask = {
	PHES.Leaf.combat_idle: BoneMask.get_full_body_no_root()
	}


static func _pick_bone_mask_for_enemy(hit: HitData, state_name: String) -> Array[int]:
	var _bone_mask: Array[int]
	_bone_mask = u.safe_get_dict_key(enemy_state_to_bone_mask, state_name, BoneMask.get_upper_body())
	return _bone_mask


## if not mentioned - will be default
static var player_action_to_bone_mask = {
	Leg.Act.idle: BoneMask.get_full_body_no_root()
	}


static func _pick_bone_mask_for_player(hit: HitData, action_name: String) -> Array[int]:
	var _bone_mask: Array[int]
	_bone_mask = u.safe_get_dict_key(player_action_to_bone_mask, action_name, BoneMask.get_upper_body())
	return _bone_mask

# endregion