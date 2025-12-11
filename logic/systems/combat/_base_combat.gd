@tool
@icon("res://-assets-/x_icons/white/icon_sword.png")

@abstract
class_name BaseCombat
extends BaseNodeCharacterSystem


const HIT_BUFFER_DURATION: float = 4.0
# var _processed_hits_buffer: Dictionary[int, float] = {}
var _character_is_attacking: bool = false

var _last_processed_hit: HitData
var _hit_tracker: EventThrottler

var _weapons: Dictionary[String, BaseWeapon] = {} # weaponID <String> to weapon <BaseWeapon>


func initialise():
	## currently _weapons are all under %bones
	var _weapons_list := get_descendants.base_weapons(get_parent_node_of_weapons())
	error_.empty_list(_weapons_list, "_weapons_list in combat")

	for weapon in _weapons_list:
		_weapons[weapon.get_weapon_id()] = weapon

	_hit_tracker = EventThrottler.new(HIT_BUFFER_DURATION)

	__log_("initialised _weapons", pp.dict_(_weapons))


@abstract func initialise_implementation() -> void


## nullable
@abstract func get_parent_node_of_weapons() -> Node3D


## guaranteed to be not empty
func get_all_weapons() -> Array[BaseWeapon]:
	return TypeCast.array_of_base_weapon(_weapons.values())


## nullable
func get_weapon_by_id(weapon_id: String) -> BaseWeapon:
	return u.safe_get_dict_key(_weapons, weapon_id, null, WL.WARN_CRUCIAL)


## non nullable
@abstract func get_character() -> BaseCharacter


## nullable
func get_last_processed_hit() -> HitData:
	return _last_processed_hit


func is_character_attacking() -> bool:
	return _character_is_attacking


## PROCESS HIT FROM MY ENEMY
# region


func apply_hit(hit_data: HitData) -> void:
	var hit_id := hit_data.get_instance_id()
	var current_time := u.get_curr_time_ticks_sec()
	
	_hit_tracker.cleanup(current_time)

	if _hit_tracker.is_throttled(hit_id, current_time):
		__log_(hit_id, "is already processed (throttled)")
		return
	else:
		__log_(hit_id, "not processed, will be")
	
	_hit_tracker.record_event(hit_id, current_time)
	
	_last_processed_hit = hit_data
	get_character().react_on_hit(hit_data)

# endregion


## PREPARE MY WEAPONS
# region

## DOCS: For simplicity set_hit_data_to_all_weapons and reset_all_weapons work with all weapons,
##   while usually we work with one specic weapon.
##   They won't do damage or leave any trace, because most important 
##   function update_weapon_is_attacking works with specific weapon name.
##   Still looks akward, switch to using all functions by weapon_name later

func set_hit_data_to_all_weapons(hit_damage: float, anim_id: String) -> void:
	var weapons := get_all_weapons()
	if weapons.is_empty():
		__log_error("no weapons", "set_hit_data_to_all_weapons", "return")
		return
	for weapon in weapons:
		var hit_data := HitData.new(hit_damage, weapon.get_weapon_id(), anim_id)
		weapon.set_hit_data(hit_data)
		__log_("set hit data to weapons", weapon, hit_data)


func update_weapon_is_attacking(weapon_name: String, is_attacking: bool) -> void:
	var weapon := get_weapon_by_id(weapon_name)
	if not weapon:
		__log_error("no weapon", "update_weapon_is_attacking", "return")
		return

	_update_is_attacking(weapon, is_attacking)


func _update_is_attacking(weapon: BaseWeapon, is_attacking: bool):
	## important these two to be atomic
	weapon.set_is_attacking(is_attacking)
	_character_is_attacking = is_attacking
	# __log_("_update_is_attacking. is_attacking/weapon", is_attacking, weapon)


func reset_all_weapons() -> void:
	var weapons := get_all_weapons()

	for weapon in weapons:
		weapon.reset_hit_data()
		weapon.reset_contact_hitbox_list()
		_update_is_attacking(weapon, false)
		# __log_("reset active weapon")

# endregion


func __LOG_B() -> bool:
	return LogToggler.FIGHT_B


func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_INDENT
