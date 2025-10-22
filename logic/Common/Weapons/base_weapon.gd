extends Node3D
class_name BaseWeapon

## Weapon consists of
# - WeaponHurtBox (area3D) - PACKED SCENE
#     - collision of area3D IS NOT in packed scene
#     - note that godot wants u to change its shape via Shape, not Scale 
# - Weapon visual mesh - optional (e.g. not visuals for leg kick)
## Also
# - Scene in owner tree should have group.
# - see description of properties below
# - see SmithSword implementation for basic approach to all this

## assigned by the holder (owner)
@export var holder: BaseCharacterBody3D

## assigned by specific implementation
var weapon_hurt_box: WeaponHurtBox
var weapon_visuals: MeshInstance3D = null
var weapon_name: String = "no_weapon_name_needs_fix"

## To get a hit only once per attack.
## If hitbox doesn't find itself in the list
##    - it registers the contact
##    - writes itself into the list to ignore all further contacts
## Usually is cleared by attack states on_exit
var hitbox_ignore_list: Array[Area3D]

## does it hurt right now, usually is managed by state
var is_attacking: bool = false


var _hit_data: HitData = null

## E.g: Sword maps 'light attack pressed' to slash, while staff to spell.
## _input_action_to_state = {
## 	CombatAction.light_attack_pressed: PS.longsword_1
## }
## NOTE: specific to player only. Is here for now for simplicity.
var _input_action_to_state: Dictionary = {} # input actions to states


func _ready():
	weapon_hurt_box.base_weapon = self
	weapon_hurt_box.collision_layer = Collision.Layers.WEAPON_AREA
	weapon_hurt_box.collision_mask = Collision.Mask.WEAPON_AREA_MASK

	if not weapon_visuals:
		print(pp.s(em.pin, "Note: Weapon", pp.in_q(weapon_name), "has no visuals"))

	assert(weapon_hurt_box is Area3D, "Weapon is missing an Area3D node named 'WeaponArea'.")
	assert(weapon_hurt_box.get_child(0), "The 'WeaponArea' must have a CollisionShape3D child.")


## can be null
func get_hit_data() -> HitData:
	return _hit_data


func translate_combat_input_to_state(combat_actions: Array) -> Array:
	var _translated = []
	
	for act in combat_actions:
		if u.safe_has_key(act, _input_action_to_state):
			_translated.append(_input_action_to_state[act])

	if not combat_actions.is_empty() and _translated.is_empty():
		print_.warn(pp.s("BaseWeapon", weapon_name, "has no map for actions", combat_actions, "mapping", _input_action_to_state))
	if not _translated.is_empty():
		print_.fight("PlCombat", pp.s("actions ", combat_actions, "translatedToSt", _translated))
	return _translated
