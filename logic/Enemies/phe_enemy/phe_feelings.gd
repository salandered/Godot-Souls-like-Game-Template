extends Node
class_name PHEFeelings


var max_health: float = 600
var health: float = 600


func lose_health(amount: float):
	health -= amount
	#if health < 1:
		#state_machine.switch_to("death")


func gain_health(amount: float):
	if health + amount <= max_health:
		health += amount
	else:
		health = max_health
