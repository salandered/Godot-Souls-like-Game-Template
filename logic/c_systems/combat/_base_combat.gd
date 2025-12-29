@tool
@icon("res://-assets-/x_icons/white/icon_sword.png")

@abstract
class_name BaseCombat
extends NodeCharacterSystem


const HIT_BUFFER_DURATION: float = 4.0

var _last_processed_hit: HitData
var _hit_tracker: EventThrottler

## While currently it's probably always has at least one weapon, 
##	system should be designed around the fact that it could be an empty dict.
## Domain wise this looks valid, e.g: character in the middle of the switching weapons, character lost its weapons etc.
var _registered_weapons: Dictionary[String, BaseWeapon] = {} # weaponID <String> to weapon <BaseWeapon>

## must be changed via activate_weapon only.
## can be empty.
## if not empty, all entries are guaranteed to be:
##  - unique
## 	- present in _registered_weapons
var _active_weapon_ids: Array[String]


func initialise(character: BaseCharacter, active_weapon_id_list_to_set: Array[String]):
	## currently _registered_weapons are all under %bones
	_register_weapons()

	for weapon: BaseWeapon in _registered_weapons.values():
		weapon.initialise(character)

	_active_weapon_ids.clear() # just in case
	for _id in _registered_weapons.keys():
		if _id in active_weapon_id_list_to_set: # after _register_weapons
			activate_weapon(_id, false)
		else:
			__log_("deactivate", "", pp.in_q(_id), __pp_weapons_info())
			_registered_weapons[_id].deactivate()

	_hit_tracker = EventThrottler.new(HIT_BUFFER_DURATION, 2.0, 3.0, "HitTracker")

	initialise_implementation()

	if __validate_dependencies():
		__log_("initialised combat", __pp_weapons_info())


## scans all the weapons under get_parent_node_of_weapons()
func _register_weapons():
	_registered_weapons = {}

	var _weapons_list := get_descendants.base_weapons(get_parent_node_of_weapons())
	error_.empty_list(_weapons_list, "_weapons_list in combat", WL.WARN_CRUCIAL)

	for weapon in _weapons_list:
		_registered_weapons[weapon.get_weapon_id()] = weapon


@abstract func initialise_implementation() -> void


## nullable
@abstract func get_parent_node_of_weapons() -> Node3D


## ACTIVE WEAPON ID
# region


func get_active_weapon_ids() -> Array[String]:
	return _active_weapon_ids


func activate_weapon(weapon_id: String, deactivate_others: bool) -> void:
	if not _registered_weapons.has(weapon_id):
		__log_warn("trying to set active weapon which is not in registered weapons", "", "active weapons won't be changed",
			"incoming weapon:", weapon_id, __pp_weapons_info())
		return
	if deactivate_others:
		var active_weapon_ids := get_active_weapon_ids().duplicate()
		for _id in active_weapon_ids:
			deactivate_weapon(_id)
	if weapon_id in _active_weapon_ids:
		__log_("activate_weapon", "already set", "incoming weapon:", weapon_id, __pp_weapons_info())
		return
	var w := _registered_weapons[weapon_id] # safe
	w.activate()
	_active_weapon_ids.append(weapon_id)
	__log_("activate_weapon", "set (and activated)", pp.in_q(weapon_id), __pp_weapons_info())


func deactivate_weapon(weapon_id: String) -> void:
	if not _registered_weapons.has(weapon_id):
		__log_warn("trying to deactivate weapon which is not in registered weapons", "", "active weapons won't be changed",
			"incoming weapon:", weapon_id, __pp_weapons_info())
		return
	if weapon_id not in _active_weapon_ids:
		__log_("activate_weapon", "already not active", "incoming weapon:", weapon_id, __pp_weapons_info())
		return
	var w := _registered_weapons[weapon_id] # safe
	w.deactivate()
	_active_weapon_ids.erase(weapon_id)
	__log_("activate_weapon", "deactivated and erased from list", pp.in_q(weapon_id), __pp_weapons_info())


func _get_active_weapon_by_id(weapon_id: String) -> BaseWeapon:
	if not weapon_id in get_active_weapon_ids():
		return
	if not _registered_weapons.has(weapon_id): # should not happen
		return
	return _registered_weapons.get(weapon_id)

# endregion


## private
func _get_all_registered_weapons() -> Array[BaseWeapon]:
	return TypeCast.array_of_base_weapon(_registered_weapons.values())

## public
func get_all_active_weapons() -> Array[BaseWeapon]:
	var _r: Array = []
	for weapon in _get_all_registered_weapons():
		if weapon.get_weapon_id() in get_active_weapon_ids():
			_r.append(weapon)
	return TypeCast.array_of_base_weapon(_r)


## nullable
func get_registered_weapon_by_id(weapon_id: String) -> BaseWeapon:
	return u.safe_get_dict_key(_registered_weapons, weapon_id, null, WL.WARN_CRUCIAL)


## non nullable
@abstract func get_character() -> BaseCharacter


## nullable
func get_last_processed_hit() -> HitData:
	return _last_processed_hit


## PROCESS HIT FROM THE OTHER CHARACTER
# region

func apply_hit(hit_data: HitData) -> void:
	var hit_id := hit_data.get_instance_id()
	

	if _hit_tracker.is_throttled(hit_id):
		__log_(hit_id, "is already processed (throttled)")
		return
	else:
		__log_(hit_id, "not processed, will be")
	
	_hit_tracker.record_event(hit_id)
	
	_last_processed_hit = hit_data
	get_character().react_on_hit(hit_data)

# endregion


## ATTACK WITH ACTIVE WEAPONS
# region

func set_hit_data(weapon_id: String, hit_damage: float, anim_id: String) -> void:
	var weapon := _get_active_weapon_by_id(weapon_id)
	if not weapon:
		return
	var hit_data := HitData.new(hit_damage, weapon.get_weapon_id(), anim_id)
	weapon.set_hit_data(hit_data)
	# __log_("set hit data to weapon", pp.in_q(weapon_id), hit_data)


func update_weapon_is_attacking(weapon_id: String, is_attacking: bool) -> void:
	var weapon := _get_active_weapon_by_id(weapon_id)
	if not weapon:
		return
	_update_is_attacking(weapon, is_attacking)


func _update_is_attacking(weapon: BaseWeapon, is_attacking: bool):
	weapon.set_is_attacking(is_attacking)
	# __log_("_update_is_attacking. is_attacking/weapon", is_attacking, weapon)


func reset_weapon_by_id(weapon_id: String) -> void:
	var weapon := _get_active_weapon_by_id(weapon_id)
	if not weapon:
		return
	weapon.reset_hit_data()
	weapon.reset_contact_hitbox_list()
	_update_is_attacking(weapon, false)
	# __log_("reset active weapon")

# endregion


## __LOGS

func __pp_weapons_info() -> String:
	return pp.s("curr active/registered:", get_active_weapon_ids(), _registered_weapons.keys())


func __LOG_B() -> bool:
	return LogToggler.FIGHT_B


func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_INDENT
