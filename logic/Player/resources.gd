extends Node
class_name HumanoidResources

@export var god_mode: bool = false

@export var health: float = 100
@export var max_health: float = 100

@export var stamina: float = 100
@export var max_stamina: float = 100
@export var stamina_regeneration_rate: float = 10 # per sec, because then we'll multiply on delta

@onready var model = $".." as PlayerModel

var statuses: Array[String]
const FATIQUE_TRESHOLD = 20


func update(delta: float):
	gain_stamina(stamina_regeneration_rate * delta)


## high-level methods to trim the bureaucracy
func pay_resource_cost(state: PlayerState):
	lose_stamina(state.stamina_cost)


func pay_block_cost(damage: float, blocking_coefficient: float):
	if damage * blocking_coefficient <= stamina:
		lose_stamina(damage * blocking_coefficient)
	else:
		var unblocked_portion = damage - stamina / blocking_coefficient
		lose_stamina(stamina)
		lose_health(unblocked_portion)
		# something punish like force guardbreak 
		print("was guardbroken")


## high-level methods to trim the bureaucracy
func can_be_paid(state: PlayerState) -> bool:
	if stamina > 0 or state.stamina_cost == 0:
		return true
	return false

# region: Variant of polymorphism, but it doesn't work
#func can_be_paid(state_name : String) -> bool:
	#var state = model.states[state_name]
	#return can_be_paid(state)
# endregion

func lose_health(amount: float):
	if not god_mode:
		health -= amount
		if health < 1:
			model.current_state.try_force_state(PS.death)


func gain_health(amount: float):
	if health + amount <= max_health:
		health += amount
	else:
		health = max_health


func lose_stamina(amount: float):
	if not god_mode:
		stamina -= amount
		if stamina < 1:
			statuses.append("fatique")
			# print("~~~ fatique")


func gain_stamina(amount: float):
	if stamina + amount < max_stamina:
		stamina += amount
	else:
		stamina = max_stamina
	if stamina > FATIQUE_TRESHOLD:
		statuses.erase("fatique")
		# print("~~~ fatique erased")
