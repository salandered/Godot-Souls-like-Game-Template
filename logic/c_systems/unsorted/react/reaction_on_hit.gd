extends RefCounted
class_name ReactionOnHit


class ReactionConfig:
	var anim_id: String
	var overlay_weight: float
	var bone_mask: Array[int]

	func _init(anim_id_: String, overlay_weight_: float, bone_mask_: Array[int]) -> void:
		self.anim_id = anim_id_
		self.overlay_weight = overlay_weight_
		self.bone_mask = bone_mask_
	
	func _to_string() -> String:
		return "anim_id: %s, wght: %.2f, %s" % [anim_id, overlay_weight, pp.bone_mask_(bone_mask)]


## todo: some smart system which detects, where we collided ...
## todo: its better to rely on state, not anim as a key
## 
## from the character point of view. Examples:
## slash from right to left - Dir is LEFT
## slash up - Dir is UP
static var enemy_attack_to_direction: Dictionary[String, AttackDirection.Dir] = {
	PHEA.attack.attack_360_high: AttackDirection.Dir.RIGHT,
	PHEA.attack.attack_360_low: AttackDirection.Dir.RIGHT,
	PHEA.attack.attack_down: AttackDirection.Dir.DOWN,
	PHEA.attack.attack_up: AttackDirection.Dir.UP,
	PHEA.attack.club_part_1: AttackDirection.Dir.LEFT,
	PHEA.attack.club_part_2: AttackDirection.Dir.RIGHT,
	PHEA.attack.club_part_3_4: AttackDirection.Dir.LEFT,
	PHEA.attack.power_gap_closer: AttackDirection.Dir.DOWN,
	PHEA.attack.sword_slide: AttackDirection.Dir.LEFT,
	PHEA.attack.scare_off: AttackDirection.Dir.STAB,
	PHEA.attack.power_up: AttackDirection.Dir.UP,
	PHEA.attack.stab_low: AttackDirection.Dir.STAB,
	PHEA.phase_switch: AttackDirection.Dir.STAB,
	}

static var pl_attack_to_direction: Dictionary[String, AttackDirection.Dir] = {
	A.attack.axe_slice_1: AttackDirection.Dir.LEFT,
	A.attack.axe_slice_2: AttackDirection.Dir.RIGHT,
	A.attack.axe_slice_3: AttackDirection.Dir.LEFT,
	A.attack.attack_from_run: AttackDirection.Dir.STAB,
	A.attack.attack_from_dodge: AttackDirection.Dir.STAB,
	A.attack.sword_slash_1: AttackDirection.Dir.LEFT,
	A.attack.sword_slash_2: AttackDirection.Dir.UP, # technically should be RIGHT
	A.attack.sword_slash_3: AttackDirection.Dir.DOWN
	}


static var attack_dir_to_enemy_overlay_anim: Dictionary[AttackDirection.Dir, String] = {
	AttackDirection.Dir.LEFT: PHEA.react.react_from_L,
	AttackDirection.Dir.RIGHT: PHEA.react.react_from_R,
	AttackDirection.Dir.UP: PHEA.react.body_impact,
	AttackDirection.Dir.DOWN: PHEA.react.react_gut,
	AttackDirection.Dir.STAB: PHEA.react.react_gut,
	}

static var attack_dir_to_pl_overlay_anim: Dictionary[AttackDirection.Dir, String] = {
	AttackDirection.Dir.LEFT: A.react.react_from_L,
	AttackDirection.Dir.RIGHT: A.react.react_from_R,
	AttackDirection.Dir.UP: A.react.head_B_large,
	AttackDirection.Dir.DOWN: A.react.react_gut,
	AttackDirection.Dir.STAB: A.react.react_gut,
	}


# todo: probably states as keys, not raw animations
## here listed only attacks which causes interrupt states
static var enemy_attack_to_pl_state_interruption: Dictionary[String, String] = {
	PHEA.attack.attack_360_low: PS.thrown,
	PHEA.attack.attack_up: PS.pushback,
	PHEA.attack.power_gap_closer: PS.thrown,
	PHEA.attack.sword_slide: PS.thrown,
	PHEA.attack.scare_off: PS.pushback,
	PHEA.attack.power_up: PS.thrown,
	PHEA.phase_switch: PS.thrown
	}


## here listed only attacks which causes interrupt states
static var pl_attack_to_enemy_state_interruption: Dictionary[String, Array] = {
	A.attack.sword_slash_3: [PHES.Leaf.pushback, 1.0],
	A.attack.axe_slice_1: [PHES.Leaf.pushback, 0.3],
	A.attack.axe_slice_2: [PHES.Leaf.pushback_2, 0.4],
	A.attack.axe_slice_3: [PHES.Leaf.pushback_2, 1.0],
	}


## only actions. If not mentioned - will be default values
static var player_muted_action: Array[String] = [PS.Act.death, PS.Act.double, Leg.Act.double]

## only leafes. If not mentioned - will be default values
static var enemy_muted_states: Array[String] = [PHES.Leaf.death, PHES.Leaf.phase_switch] # PHES.Leaf.sleep] dev


static func get_attack_dir_by_enemy_attack(anim_id: String) -> AttackDirection.Dir:
	return u.safe_get_dict_key(enemy_attack_to_direction, anim_id, AttackDirection.Dir.RIGHT)


## nullable
static func calculate_reaction_for_pl_action(hit: HitData, curr_action: String) -> ReactionConfig:
	if curr_action in player_muted_action:
		__log_("Player reaction muted. Action:", curr_action, "Hit:", hit.anim_id)
		return null
	var overlay_weight: float
	if hit.damage < 1.0:
		overlay_weight = 0.0
	else:
		overlay_weight = _pick_overlay_weight(hit, Constants.ENEMY_MAX_HIT_DAMAGE - 0.5)
	
	var anim_id_: String
	anim_id_ = _pick_react_anim_for_player(hit)

	var bone_mask := _pick_bone_mask_for_player(hit, curr_action)
	
	var react_cfg := ReactionConfig.new(anim_id_, overlay_weight, bone_mask)
	__log_("Player Reaction CFG:", react_cfg)
	return react_cfg


## nullable
static func calculate_reaction_for_enemy(hit: HitData, curr_leaf_state: String) -> ReactionConfig:
	if curr_leaf_state in enemy_muted_states:
		__log_("Enemy reaction muted. State:", curr_leaf_state, "Hit:", hit.anim_id)
		return null
	var overlay_weight: float
	if hit.damage < 1.0:
		overlay_weight = 0.0
	else:
		overlay_weight = _pick_overlay_weight(hit, Constants.PLAYER_MAX_HIT_DAMAGE)
	
	var anim_id_: String
	anim_id_ = _pick_react_anim_for_enemy(hit)

	var bone_mask := _pick_bone_mask_for_enemy(hit, curr_leaf_state)
	
	var react_cfg := ReactionConfig.new(anim_id_, overlay_weight, bone_mask)
	__log_("Enemy Reaction CFG:", react_cfg)
	return react_cfg


## PICK REACT ANIM
# region

static func _pick_react_anim_for_enemy(hit_from_player: HitData) -> String:
	var _attack_dir = u.safe_get_dict_key(pl_attack_to_direction, hit_from_player.anim_id, AttackDirection.Dir.RIGHT)
	var _anim_id = u.safe_get_dict_key(attack_dir_to_enemy_overlay_anim, _attack_dir, PHEA.react.react_from_R)
	__log_("pl attack", pp.in_q(hit_from_player.anim_id), "-> Dir", AttackDirection.name_(_attack_dir), "-> Ovrl anim", _anim_id)
	return _anim_id


static func _pick_react_anim_for_player(hit_from_enemy: HitData) -> String:
	var _attack_dir = u.safe_get_dict_key(enemy_attack_to_direction, hit_from_enemy.anim_id, AttackDirection.Dir.RIGHT)
	var _anim_id = u.safe_get_dict_key(attack_dir_to_pl_overlay_anim, _attack_dir, A.react.react_from_R)
	__log_("e attack", pp.in_q(hit_from_enemy.anim_id), "-> Dir", AttackDirection.name_(_attack_dir), "-> Ovrl anim", _anim_id)
	return _anim_id

# endregion


static func _pick_overlay_weight(hit: HitData, max_damage: float) -> float:
	var linear_value := hit.damage / max_damage
	var clamped_linear := clampf(linear_value, 0.0, 1.0)

	
	# 0.3: low hits - more weight
	# 0.7: low hits - less
	# if 0.5:
	# [10, 35] (max 35) -> [0.54, 1.0]
	# [10, 15] (max 15) -> [0.82, 1.0]
	var eased_value := ease(clamped_linear, 0.3) # ease out
	__log_("Dmg/Max", hit.damage, max_damage, "-> Linear", clamped_linear, "-> Eased", eased_value)
	return eased_value


## PICK BONE MASK
# region


## if not mentioned - will be default
static var enemy_state_to_bone_mask = {
	PHES.Leaf.combat_idle: BoneMask.get_full_body_no_root()
	}


static func _pick_bone_mask_for_enemy(hit: HitData, state_name: String) -> Array[int]:
	var _bone_mask: Array[int]
	_bone_mask = u.safe_get_dict_key(enemy_state_to_bone_mask, state_name, BoneMask.get_upper_body(), WL.SILENT)
	__log_("EState", pp.in_q(state_name), "->", pp.bone_mask_(_bone_mask))
	return _bone_mask


## if not mentioned - will be default
static var player_action_to_bone_mask = {
	# Leg.Act.idle: BoneMask.get_full_body_no_root()
	}


static func _pick_bone_mask_for_player(hit: HitData, action_name: String) -> Array[int]:
	var _bone_mask: Array[int]
	_bone_mask = u.safe_get_dict_key(player_action_to_bone_mask, action_name, BoneMask.get_upper_body_with_hips(), WL.SILENT)
	__log_("PLAction", pp.in_q(action_name), "->", pp.bone_mask_(_bone_mask))
	return _bone_mask

# endregion


## STATE REACT
# region


## may return ""
static func calculate_reaction_for_pl_state(hit_from_enemy: HitData) -> String:
	var _pl_state: String
	_pl_state = u.safe_get_dict_key(enemy_attack_to_pl_state_interruption, hit_from_enemy.anim_id, "", WL.SILENT)
	__log_("Hit", pp.in_q(hit_from_enemy.anim_id), "-> Player State Interruption", pp.in_q(_pl_state))
	return _pl_state

## may return ""
static func calculate_reaction_for_enemy_state(hit_from_pl: HitData) -> String:
	var _e_state = ""
	var _e_state_and_probability: Array
	_e_state_and_probability = u.safe_get_dict_key(pl_attack_to_enemy_state_interruption, hit_from_pl.anim_id, ["", 0.0], WL.SILENT)
	_e_state = _e_state_and_probability[0] if ra.chance(_e_state_and_probability[1]) else ""
	__log_("Hit", pp.in_q(hit_from_pl.anim_id), "-> Enemy State Interruption. State/probability/result",
		pp.s(_e_state_and_probability[0], _e_state_and_probability[1], _e_state))
	return _e_state

# endregion


static func __log_(...parts: Array):
	if LogToggler.REACT_UTILS_B:
		print_.prefix_s("[🗣️ReactionOnHits]", pp.list_(parts))
