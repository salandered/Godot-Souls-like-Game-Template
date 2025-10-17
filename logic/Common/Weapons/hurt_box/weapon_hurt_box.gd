@tool
@icon("res://-assets-/x_misc/x_icons/red/hurt_box_3d.svg")
extends Area3D

## Weapon area which DAMAGES.
## HitBox registers collision with it and uses base_weapon for calculations
class_name WeaponHurtBox

## base_weapon is assigned in BaseWeapon with itself
## => on contact with other area it can provide all weapon info
var base_weapon: BaseWeapon
