@tool
@icon("res://-assets-/x_icons/char/image (22).png")
extends PHCharacter
class_name SittingSkCharacter


@onready var _visual_offset: Node3D = %VisualOffset
@onready var aura_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %AuraAnimSFXSigEmitter


func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]:
	return {
			WeaponID.bg_aura_weapon: aura_anim_sfx_sig_emitter
		}
func _for_init_anim_list() -> BaseCharAnimList:
	return SITSKA.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return SitSkRequiredMarkers.anim_to_required_marker
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.bg_aura_weapon]
func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer:
	return SitSkASPConfigContainer.new()
##


func initialise_phe_char_implementation() -> void:
	pass
##

func get_initial_leaf_state_name() -> String:
	return SITSKS.Leaf.sit_idle_v1


func get_visuals_root() -> Node3D:
	return _visual_offset


func get_node_state_container() -> PHEBaseNodeStateDataContainer:
	return SitSKNodeStateDataContainer.new()


##


func get_power_attacks_state_names() -> Array[String]:
	return [
		SITSKS.Leaf.sit_attack
	   ]
