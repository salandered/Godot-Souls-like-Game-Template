extends LimboState


@onready var target_sensor: AreaEnemyTargetSensor = %AreaEnemyTargetSensor
@onready var anim_tree = %AnimationTree

const TO_DEFAULT_TARGET := &"TO_DEFAULT_TARGET"
@onready var combat_timer: Timer = %CombatTimer
@onready var chase_timer: Timer = %ChaseTimer

enum ChaseSubState {
	CHASE,
	COMBAT
}


var cur_chase_substate: ChaseSubState

signal attack_started
signal retreat_started

func _setup() -> void:
	combat_timer.timeout.connect(_on_combat_timer_timeout)
	chase_timer.timeout.connect(_on_chase_timer_timeout)

	# TODO: refactor logic after understanding it (move to npc?)
	target_sensor.target_lost.connect(_on_target_lost)

	attack_started.connect(_on_attack_started)
	retreat_started.connect(_on_retreat_started)


func _enter() -> void:
	print("|| NPC entered ", name)
	cur_chase_substate = ChaseSubState.CHASE

	chase_timer.start()
	

func _update(_delta: float) -> void:
	var npc := agent
	
	npc.apply_gravity(_delta)
	if cur_chase_substate == ChaseSubState.COMBAT:
		anim_tree.set_movement("Combat")
	else:
		anim_tree.set_movement()
	
	npc.rotate_character()
	npc.update_direction()
	npc.free_movement(_delta)
	evaluate_state()

	# print("chase_timer ", chase_timer.time_left)
	# print("combat_timer ", combat_timer.time_left)

	npc.move_and_slide()


func evaluate_state():
	var npc := agent
	# if npc.target == npc.default_target:
		# get_root().dispatch(TO_DEFAULT_TARGET)

	var target_distance = npc.get_target_distance()
	# print("Target distance ", target_distance)
	if target_distance > npc.combat_range and cur_chase_substate != ChaseSubState.CHASE:
		print("Switched to Chase substate ", target_distance)
		cur_chase_substate = ChaseSubState.CHASE

	elif target_distance <= npc.combat_range and combat_timer.is_stopped():
		print("Switched to Combat substate ", target_distance)
		cur_chase_substate = ChaseSubState.COMBAT
		combat_timer.start()
		

func _combat_randomizer():
	print("_combat_randomizer")
	var random_choice = randi_range(1, 10)
	if random_choice <= 3:
		retreat_started.emit() # Back away for a period of time
	else:
		attack_started.emit()

func _on_attack_started():
	print("SIG _on_attack_started")
	anim_tree.attack()


func _on_retreat_started():
	print("SIG _on_retreat_started")
	anim_tree.retreat()

func _on_combat_timer_timeout():
	print("SIG _on_combat_timer_timeout")
	if cur_chase_substate == ChaseSubState.COMBAT:
		_combat_randomizer()


func _on_target_lost():
	print("SIG _on_target_lost, target", agent.target)
	if is_instance_valid(agent.target):
		if is_instance_valid(chase_timer): # just trying to quiet some errors
			chase_timer.start() # TODO: end?


func _on_chase_timer_timeout():
	print("SIG _on_chase_timer_timeout, target", agent.target)

	if cur_chase_substate != ChaseSubState.COMBAT and agent.get_target_distance() > 10:
		# give up
		await get_tree().create_timer(2).timeout
		get_root().dispatch(TO_DEFAULT_TARGET)
		# agent.target = agent.default_target