extends CharacterBody3D

@export var speed: float = 4.0
@export_range(1.0, 40.0, 1.0) var gravity := 17.0
@export var combat_range: float = 2

@onready var target_sensor: AreaEnemyTargetSensor = %AreaEnemyTargetSensor
## Enemy follows it after giving up the chase. Can be
##   * usually pathfollow node, following a Path.
##   * if left blank, the same location where enemy spawns.
@export var default_target: Node3D
@export var health_system: HealthSystem


@onready var hurt_cool_down = Timer.new()
@onready var nav_agent_3d = $NavigationAgent3D


@onready var direction: Vector3 = Vector3.ZERO
@onready var spawn_location: Marker3D = Marker3D.new()


@onready var general_skeleton = %GeneralSkeleton

signal hurt_started
signal damage_taken
signal parried_started

@onready var state_machine: LimboHSM = $LimboHSM


@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var chase_state: LimboState = $LimboHSM/ChaseState
@onready var return_state: LimboState = $LimboHSM/ReturnState
@onready var dead_state: LimboState = $LimboHSM/DeadState

var target: Node3D
var group_name: String = "targets"

# HEALTH

@export var show_time: float = 2
var show_health_timer: Timer


# ANIM
@onready var anim_tree = %AnimationTree
@onready var anim_length := 0.5

@export var max_attack_count: int = 2

@onready var hurt_count: int = 1

signal animation_measured(anim_length) # emitted in _on_animation_started

func _ready():
	add_to_group(group_name)
	collision_layer = 5

	damage_taken.connect(_on_damage_taken)
	target_sensor.target_spotted.connect(_on_target_spotted)
	

	hurt_cool_down.one_shot = true
	hurt_cool_down.wait_time = .4
	add_child(hurt_cool_down)

	_set_default_target()

	_init_state_machine()

	health_system.health_bar_control.hide()
	show_health_timer = Timer.new()
	show_health_timer.one_shot = true
	show_health_timer.wait_time = show_time
	show_health_timer.timeout.connect(_on_show_timer_timeout)
	add_child(show_health_timer)


	hurt_started.connect(_on_hurt_started)
	# parried_started.connect(_on_parried_started)
	# anim_tree.animation_measured.connect(_on_animation_measured)
	# anim_tree.animation_started.connect(_on_animation_started)

func _init_state_machine():
	# IDLE
	# state_machine.add_transition(idle_state, chase_state, idle_state.TO_CHASE)
	# CHASE
	state_machine.add_transition(chase_state, return_state, chase_state.TO_DEFAULT_TARGET)
	# RETURN
	state_machine.add_transition(return_state, idle_state, return_state.RETURNED)
	# DEAD
	# state_machine.add_transition(state_machine.ANYSTATE, dead_state, DIED_EVENT)

	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

func _set_default_target():
	## Creates a node to return to after patrolling if no default target is set.
	add_child(spawn_location)
	spawn_location.top_level = true
	spawn_location.global_position = to_global(Vector3(0, 0, 0.2))
	if not default_target:
		print("SPAWN")
		print(spawn_location)
		print(spawn_location.global_position)
		default_target = spawn_location
	target = default_target

func _process(delta):
	pass

		
func _physics_process(_delta):
	# from health
	if show_health_timer:
		if show_health_timer.time_left:
			show_health()



func get_target_distance() -> float:
	return target.global_position.distance_to(global_position)

func show_health():
	var current_camera = get_viewport().get_camera_3d()
	var screenspace = current_camera.unproject_position(global_position)
	health_system.health_bar_control.position = screenspace
	health_system.health_bar_control.show()


func free_movement(delta):
	var rate: float # imitates directional change acceleration rate
	if is_on_floor():
		rate = .5
	else:
		rate = .1
	var new_velocity = get_quaternion() * anim_tree.get_root_motion_position() / delta

	if is_on_floor():
		velocity.x = move_toward(velocity.x, new_velocity.x, rate)
		velocity.y = move_toward(velocity.y, new_velocity.y, rate)
		velocity.z = move_toward(velocity.z, new_velocity.z, rate)
	else:
		velocity.x = move_toward(velocity.x, _calc_direction().x * speed, rate)
		velocity.z = move_toward(velocity.z, _calc_direction().z * speed, rate)
		
func _calc_direction() -> Vector3:
	var new_direction = global_transform.basis.z
	return new_direction

		
func update_direction():
	nav_agent_3d.target_position = target.global_position
	var new_dir = (nav_agent_3d.get_next_path_position() - global_position).normalized()
	new_dir *= Vector3(1, 0, 1) # no Y value so enemy stays at current level
	direction = new_dir
		
func rotate_character():
	var rate = .2
	var new_dir = global_position.direction_to(nav_agent_3d.get_next_path_position())
	var current_rotation = global_transform.basis.get_rotation_quaternion()
	var target_rotation = current_rotation.slerp(Quaternion(Vector3.UP, atan2(new_dir.x, new_dir.z)), rate)
	global_transform.basis = Basis(target_rotation)

func apply_gravity(_delta):
	if not is_on_floor():
		velocity.y -= gravity * _delta


func hit(_by_who, _by_what):
	# called from player
	target = _by_who
	if hurt_cool_down.is_stopped():
		hurt_cool_down.start()
		hurt_started.emit() # caught in anim tree
		damage_taken.emit(_by_what)

func _on_target_spotted(_spotted_target):
	# emitted from TargetSensor 
	print("_on_target_spotted ")
	print("     > active state: ", state_machine.get_active_state())
	if state_machine.get_active_state() not in [chase_state, dead_state]:
		print("          > Change to chase state")
		state_machine.change_active_state(chase_state)
	else:
		print("          > already active state, not changing")
	if target != _spotted_target:
		target = _spotted_target
	else:
		print("          > already target is player, not changing")
	

func _on_damage_taken(_by_what):
	# emitted by hit
	show_health_timer.start()
	var damage_power = _by_what.power
	health_system.current_health -= damage_power
	health_system.health_updated.emit(health_system.current_health) # for health_bar
	if health_system.current_health <= 0:
		print("--- check this part --- ")
		print("Change to dead state")
		if state_machine.get_active_state() not in [dead_state]:
			state_machine.change_active_state(dead_state)

func parried():
	pass
	# Turned off for now
	# called from player
	# if hurt_cool_down.is_stopped():
		# hurt_cool_down.start()
		# parried_started.emit()


func _on_show_timer_timeout():
	health_system.health_bar_control.hide()


func _on_hurt_started():
	hurt_count = randi_range(1, 2)
	anim_tree.hurt()


# func _on_parried_started():
# 	_abort_oneshot(last_oneshot)
# 	_request_oneshot("parried")


# func _on_animation_started(anim_name):
# 	anim_length = get_node(anim_tree.anim_player).get_animation(anim_name).length
# 	animation_measured.emit(anim_length)

# func _on_animation_measured(_new_length):
# 	anim_length = _new_length - 0.05 # offset slightly for the process frame
