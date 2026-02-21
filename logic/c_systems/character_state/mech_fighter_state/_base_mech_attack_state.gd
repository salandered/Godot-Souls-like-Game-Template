@abstract
class_name BaseMechAttackState
extends BaseMechFighterState


var hit_damage: float = 10


var SCALE_ROOT_FACTOR := 1.0


func initialise() -> void:
	TIME_REMAINING_TO_END = 0.2
	initialise_attack_state_implementation()


func initialise_attack_state_implementation() -> void:
	pass


var default_attack_weapons: Array[StringName] = [WeaponID.fighter_h_arm]

## what weapons should be attacking in this state (depends on animation)
## to override
func get_anim_active_weapon_ids() -> Array[StringName]:
	return default_attack_weapons


func _combat_set_hit_data():
	for weapon_id in get_anim_active_weapon_ids():
		me.get_combat().set_hit_data(
			weapon_id,
			hit_damage,
			anim.anim_id,
			me.get_animator_manager().get_global_speed_scale(),
			state_name,
			)

func _combat_update_is_attacking():
	var _weapon_ids := get_anim_active_weapon_ids()
	for _id in _weapon_ids:
		me.get_combat().update_weapon_is_attacking(_id, is_weapon_hurts(_id, false))

func _combat_reset():
	for weapon_id in get_anim_active_weapon_ids():
		me.get_combat().reset_weapon_by_id(weapon_id)


func on_enter_state() -> void:
	_combat_set_hit_data()
	on_enter_attack_state_implementation()
	
	
func on_enter_attack_state_implementation():
	pass

func on_exit_state() -> void:
	_combat_reset()
	on_exit_attack_state_implementation()
	
	
func on_exit_attack_state_implementation():
	pass


func update(delta: float):
	_combat_update_is_attacking()
	update_attack_state_implementation()


func update_attack_state_implementation():
	pass
