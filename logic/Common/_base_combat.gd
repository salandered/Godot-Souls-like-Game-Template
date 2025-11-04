@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")

@abstract
class_name BaseCombat
extends Node


var _processed_hits: Dictionary = {}
const HIT_BUFFER_DURATION: float = 4.0


func _is_hit_processed(hit_id: int) -> bool:
	return _processed_hits.has(hit_id)


func _mark_hit_processed(hit_id: int) -> void:
	_processed_hits[hit_id] = Time.get_ticks_msec() / 1000.0


func _cleanup_old_hits() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var to_remove: Array = []
	
	for hit_id in _processed_hits:
		if current_time - _processed_hits[hit_id] > HIT_BUFFER_DURATION:
			to_remove.append(hit_id)
	
	__log_("_cleanup_old_hits, to_remove", to_remove)
	for hit_id in to_remove:
		_processed_hits.erase(hit_id)


## nullable
@abstract func get_active_weapon() -> BaseWeapon

@abstract func is_player() -> bool

## non nullable
@abstract func get_me() -> BaseCharacter


@abstract func get_combat_name() -> String


func apply_hit(hit_data: HitData) -> void:
	var hit_id = hit_data.get_instance_id()
	
	if _is_hit_processed(hit_id):
		__log_(hit_id, "is already processed")
		return
	else:
		__log_(hit_id, "not processed")

	_mark_hit_processed(hit_id)
	_cleanup_old_hits()
	
	get_me().react_on_hit(hit_data)


func set_hit_data_to_weapon(hit_damage: float, anim_id: String) -> void:
	var weapon := get_active_weapon()
	if not weapon:
		__log_warn("no weapon", "set_hit_data_to_weapon", "return")
		return
	var hit_data := HitData.new(hit_damage, weapon, anim_id)
	weapon.set_hit_data(hit_data)
	__log_("set hit data to active weapon", weapon, hit_data)


func update_is_attacking(is_attacking: bool) -> void:
	var weapon := get_active_weapon()
	if not weapon:
		__log_warn("no weapon", "update_is_attacking", "return")
		return
	weapon.set_is_attacking(is_attacking)


func reset_active_weapon() -> void:
	var weapon := get_active_weapon()
	if not weapon:
		__log_warn("no weapon", "reset_active_weapon", "return")
		return
	weapon.reset_hit_data()
	weapon.reset_contact_hitbox_list()
	weapon.set_is_attacking(false)
	# __log_("reset active weapon")


## __LOGS

func __log_(...parts: Array):
	# using weapon holder as name of BaseCombat
	if is_player(): print_.fight(get_combat_name(), pp.list_(parts))


func __log_warn(what: String, where: String, fallback: String):
	print_.warn(false, what, "BaseCombat " + where, fallback)
