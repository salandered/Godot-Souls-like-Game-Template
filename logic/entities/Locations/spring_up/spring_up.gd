@tool
@icon("res://-assets-/x_icons/red/double_up.png")
class_name SpringUp
extends Node3DSystem

@export var lift_height: float = 6.0
@export var lift_duration: float = 0.4 # How many seconds the lift takes
@export var velocity_influence: float = 0.5 # How much the incoming velocity affects height
@export var inertia: bool = false # How much the incoming velocity affects height

@onready var monitor_player_enter_signal_area: MonitorPlayerEnterSignalArea = %MonitorPlayerEnterSignalArea
@onready var interact_area: InteractArea = %InteractArea
@onready var whoosh_1: AudioStreamPlayer3D = %WHoosh1
@onready var whoosh_2: AudioStreamPlayer3D = %Whoosh2

var _target_player: Princess
var _time_elapsed: float = 0.0
var _start_y: float = 0.0

func __hard_dependencies() -> Array:
	return [monitor_player_enter_signal_area]

func __soft_dependencies() -> Array:
	return [interact_area, whoosh_1, whoosh_2]

func _ready() -> void:
	set_physics_process(false)
	if Engine.is_editor_hint(): return
	if __perform_validation():
		monitor_player_enter_signal_area.SIG_player_entered.connect(on_player_entered)


func on_player_entered(incoming_body: Node3D):
	if incoming_body is not Princess: return
	
	_target_player = incoming_body
	
	# Capture velocity BEFORE disabling physics
	var incoming_y_velocity := _target_player.velocity.y
	
	# Calculate dynamic height: Base Height + (Velocity * Multiplier)
	# use max() to ensure we don't accidentally spring downwards if falling very fast
	# flip the sign if falling (negative velocity) to make it add to the bounce
	var bonus_height := absf(incoming_y_velocity) * velocity_influence
	var final_height := lift_height + bonus_height
	
	_target_player.set_physics_process(false)
	_target_player.set_process(false)
	_target_player.velocity = Vector3.ZERO
	
	_start_y = _target_player.global_position.y
	_current_target_height = final_height
	_time_elapsed = 0.0
	
	set_physics_process(true)
	_play_spring_effects()

var _current_target_height: float = 0.0


func _physics_process(delta: float) -> void:
	if not _target_player:
		set_physics_process(false)
		return

	_time_elapsed += delta
	var progress := clampf(_time_elapsed / lift_duration, 0.0, 1.0)
	
	var ease_progress := -progress * (progress - 2.0)
	
	var new_y := _start_y + (_current_target_height * ease_progress)
	_target_player.global_position.y = new_y
	
	if progress >= 1.0:
		_finish_lift()


func _finish_lift() -> void:
	if _target_player:
		_target_player.set_physics_process(true)
		_target_player.set_process(true)
		
		if inertia:
			_target_player.velocity.y = lift_height / lift_duration * 0.5
		
		_target_player = null
		
	set_physics_process(false)


func _play_spring_effects():
	if whoosh_1: whoosh_1.play()
	if whoosh_2: whoosh_2.play(0.14)


## 

func __LOG_B() -> bool:
	return false
