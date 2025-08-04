extends StateUtils
class_name BaseSEState
# TODO Consider: Common ancestor class State for BaseSEState and BaseSEState
#  - player state relies on input-dependent transitions and updates, whereas the enemy state does not
#    => only some fields and reaction logic would be shared, making the classes similar but not unified

@export var state_name: String
@export var animation: String

var me: CharacterBody3D
var player: CharacterBody3D

var container: SEStatesContainer
var animator: AnimationPlayer
var resources: EnemyResources
var right_weapon: WeaponOh

var spawn_point: Vector3

func check_transition(delta: float) -> String:
	assert(false, "implement transition logic for " + state_name)
	return ""

func update(delta):
	pass
 

func on_enter():
	pass


func on_exit():
	pass


func react_on_hit(hit: HitData):
	resources.lose_health(hit.damage)
