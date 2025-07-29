extends Area3D
# TODO: change to Weapon or BaseWeapon
class_name WeaponOh

## To get a hit only once per attack.
## If hitbox doesn't find itself in the list
##    - it registers the contact
##    - writes itself into the list to ignore all further contacts
## Being cleared by attack states at the end of their life cycle
var hitbox_ignore_list: Array[Area3D]

## deciding between casual animation and a strike
var is_attacking: bool = false

@export var weapon_name: String
@export var holder: Node

@export var base_damage: float = 10


## Maps input actions to states.
## Examples: sword map 'light attack pressed' to slash, while stuff to spell.
var basic_attacks: Dictionary

func get_hit_data() -> HitData:
	print("someone tries to get hit by default WeaponOh")
	return HitData.blank()


## MVC PAC Ep. 3
# Overall Godot gravitates more to the sword scene = [model scene child + visuals scene child] solutions. 
# You can have it on the same layer as player. In this case you will need to expose some socket-like tech 
# to make your player be able to hold things that are not player's scene. In the long run I thing it is the 
# cleanest approach of all, especially for a singleplayer game, because with such holding-socket tech you 
# are not limited to weapons and can transition to player-carrying-things mechanics really smooth and fast.
