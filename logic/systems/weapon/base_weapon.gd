@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")

@abstract
class_name BaseWeapon
extends BaseNode3DCharacterSystem

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. not visuals for leg kick)
# - WeaponSFX packed scene

## Also
# - see SmithSword implementation for basic approach to all this

## assigned by the holder (owner)
@export var holder: BaseCharacter

## managed by implementation
var _weapon_hurt_box: WeaponHurtBox

## To get a hit only once per attack.
## Hitbox A on contact: 
##    - if A not on the list, writes itself to the list
##    - Further contacts of A with this weapon will be ignored
## Usually is cleared by attack states on_exit()
var _contact_hitbox_list: Array[CharacterHitbox]

## does it hurt right now, usually is managed by state
var _is_attacking: bool = false


## manipulated by combat 
var _hit_data: HitData = null


var _signal_container: BaseWeaponSignalContainer

func _ready() -> void:
	_weapon_hurt_box = get_weapon_hurt_box()
	assert(_weapon_hurt_box, "No _weapon_hurt_box provided for " + get_weapon_pp_name())
	assert(_weapon_hurt_box.get_child(0), "The _weapon_hurt_box must have a CollisionShape3D. " + get_weapon_pp_name())
	assert(holder, "Set holder! for " + get_weapon_pp_name())
	
	_weapon_hurt_box.base_weapon = self

	if not get_weapon_visuals():
		pass
		# print_.note(false, "Note: Weapon", pp.in_q(get_weapon_pp_name()), "has no visuals")
	
	## each weapon has its own signals
	_signal_container = BaseWeaponSignalContainer.new()


	## SFX
	var _weapon_sfx := _get_weapon_sfx()
	if _weapon_sfx:
		_set_whoosh_weapon_stream(_weapon_sfx)
		_set_hit_weapon_stream(_weapon_sfx)
		var _sfx_system := _get_weapon_sfx_system(_weapon_sfx)
		_sfx_system.initialise(_signal_container, self, {})

	_weapon_hurt_box.initialise()
	initialise_implementation()


## additional init or validation if needed
@abstract func initialise_implementation() -> void


@abstract func get_weapon_hurt_box() -> WeaponHurtBox


func pp_name() -> String:
	return pp.s("🗡️ Weapon", get_weapon_pp_name())


@abstract func get_weapon_pp_name() -> String

## could be nullable (aura weapon)
@abstract func get_weapon_visuals() -> MeshInstance3D


func is_attacking() -> bool:
	return _is_attacking


func set_is_attacking(is_attacking_: bool) -> void:
	_is_attacking = is_attacking_


## HIT DATA
# region

## nullable
func get_hit_data() -> HitData:
	return _hit_data


func set_hit_data(hit_data: HitData):
	_hit_data = hit_data


func reset_hit_data():
	_hit_data = null

# endregion


## CONTACT HITBOX LIST MANAGEMENT
# region

func get_contact_hitbox_list() -> Array[CharacterHitbox]:
	return _contact_hitbox_list


func is_in_contact_hitbox_list(hitbox: CharacterHitbox) -> bool:
	return hitbox in _contact_hitbox_list


func add_hitbox_to_contact_list(hitbox: CharacterHitbox) -> void:
	if is_in_contact_hitbox_list(hitbox):
		__log_error("wanted to add hitbox to contact list. but its there already", "add_hitbox_to_contact_list", "not add", str(hitbox))
		return
	__log_("Added", pp.in_q(hitbox), "to contact list", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list.append(hitbox)


func reset_contact_hitbox_list() -> void:
	# __log_("Reset contact HitB list from", pp.in_q(_contact_hitbox_list))
	_contact_hitbox_list = []

# endregion


## SFX

func _get_weapon_sfx() -> WeaponSFX:
	if not _get_weapon_sfx_():
		__log_error("no _get_weapon_sfx_", "", "all sfx set up is skipped for weapon")
	return _get_weapon_sfx_()


@abstract func _get_weapon_sfx_() -> WeaponSFX


@abstract func _get_weapon_whoosh_stream() -> AudioStream

@abstract func _get_hit_weapon_stream() -> AudioStream


## public
func get_signal_container() -> BaseWeaponSignalContainer:
	return _signal_container


func _get_weapon_sfx_system(weapon_sfx: WeaponSFX) -> BaseWeaponSFXSystem:
	return weapon_sfx.get_sfx_system()


func _set_whoosh_weapon_stream(weapon_sfx: WeaponSFX):
	weapon_sfx.set_whoosh_weapon_stream(_get_weapon_whoosh_stream())

func _set_hit_weapon_stream(weapon_sfx: WeaponSFX):
	weapon_sfx.set_hit_weapon_stream(_get_hit_weapon_stream())

## in theory could be nullable
# # @abstract func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream
# func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream:
# 	return null


# func play_swing_sfx() -> void:
# 	var player = get_sfx_swing_player()
# 	if player:
# 		# Randomize pitch for realism
# 		player.pitch_scale = randf_range(0.9, 1.1)
# 		player.play()

# func resolve_hit(target: Node3D) -> void:
# 	# SFX
# 	var player = get_sfx_hit_player()
# 	if player:
# 		var stream = get_sfx_hit_stream_for_target(target)
# 		if stream:
# 			player.stream = stream
# 			player.pitch_scale = randf_range(0.9, 1.1)
# 			player.play()
	
# 	# Apply Damage / Physics (Existing logic can go here later)
# 	__log_("Resolved hit on", target.name)


## __LOGS
# region

func __LOG_B():
	return LogToggler.WEAPON_B

func __LOG_INDENT() -> int:
	return 0

func _to_string() -> String:
	return "ID '%s' wepName '%s' Holder '%s' Len of ContactHiBList '%d' isAttack '%s' HitData '%s'" \
		% [str(get_instance_id()), get_weapon_pp_name(), holder.name, len(get_contact_hitbox_list()), str(_is_attacking), str(_hit_data)]

# endregion
