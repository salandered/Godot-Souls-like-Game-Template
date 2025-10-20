extends Node
class_name PlayerFeelings


@export var max_health: int = 100
var current_health: int 
@export var max_stamina: int = 100
var current_stamina: int 


signal SIG_health_changed(new_health: float)
signal SIG_stamina_changed(new_health: float)

func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina


func change_health(amount: int) -> void:
	var new_health := current_health + amount
	
	current_health = clamp(new_health, 0, max_health)

	SIG_health_changed.emit(current_health)
	print("Changed health ", amount)

func change_stamina(amount: int) -> void:
	# TODO: not its the same as health but actually it should work differently
	# when u sprint run stamina decreases constantly
	var new_stamina := current_stamina + amount

	current_stamina = clamp(new_stamina, 0, max_stamina)
	
	SIG_stamina_changed.emit(current_stamina)
	print("Changed stamina ", amount)


# # --- Example of how to use it (optional, for testing) ---
# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("t1"):
# 		change_health(10)
# 		change_stamina(15)

# 	if event.is_action_pressed("t2"):
# 		change_health(-10)
# 		change_stamina(-15)
		
