class_name AI extends RefCounted

enum Events {
	NONE,
	FINISHED,
	PLAYER_ENTERED_LINE_OF_SIGHT,
	PLAYER_EXITED_LINE_OF_SIGHT,
	PLAYER_ENTERED_ATTACK_RANGE
}

# small virtual base class that every state will implement and that the state machine will control.
# Inner class to define the state. 
# While we could create one script per state, we'd get a lot of files to juggle. 
#Inner classes allow for multiple class definitions in a single file, 
#so we can see our entire logic at once. 
#We'll be able to access the state classes from anywhere by prepending them with the AI class name. 
#For example, AI.State will refer to the State class, and AI.Events will refer to the Events enum.
class State extends RefCounted:
	## Emitted when the state completes and the state machine should transition to the next state.
	## Use this for time-based states or moves that have a fixed duration.
	signal finished

	var name := "State" # Display name of the state, for debugging purposes. We'll use this property to display the state name on a 3D label floating above the mob.
	var mob: Mob3D = null # Reference to the mob that the state controls.
	# State class is separate from the mob script. However, the state machine still needs to access 
	# the mob to read properties or trigger animations. We define a mob property in the State class for that. 
	# To make things simple, we will ensure each state has a mob by making the _init() function request a mob 
	# node to act on. When creating the state, we will pass the player.
	# _init() is called anytime you use .new() to create an object
	# 
	#How is it different from _ready()?
	#ready() is only for nodes, not for any object. ready() also runs at a different moment.
	#_init() runs when the object is created.
	#ready() runs when the node is added to the scene tree.
	func _init(init_name: String, init_mob: Mob3D) -> void:
		name = init_name
		mob = init_mob

	## Called by the state machine on the engine's physics update tick. (in _physics_process)
	## Returns an event that the state machine can use to transition to the next state.
	## If there is no event, return [constant AI.Events.None]
	#  We only want one state to run at a time, so the state machine tracks the current state and calls its update function every physics frame. That's where you would write the code to turn towards the player.
	func update(_delta: float) -> Events:
		return Events.NONE

	## Called by the state machine upon changing the active state.
	#  runs the code when starting the state. This is where you would put the code to start a timer or limit the state duration.
	func enter() -> void:
		pass

	## Called by the state machine before changing the active state. Use this function
	## to clean up the state.
	#  used to clean up a state on exit and do things like resetting a timer or playing a visual effect
	func exit() -> void:
		pass

class StateIdle extends State:
	func _init(init_mob: Mob3D) -> void:
		super("Idle", init_mob)
		
	func enter() -> void:
		print("AI StateIdle enter")
		# It's also a perfect place to start playing sounds, particles, or any other effect that should play when the state begins.
		mob.skin.play("idle")

	func update(_delta: float) -> Events:
		#print("AI StateIdle update")
		var distance := mob.global_position.distance_to(BlackboardPlayer.player_global_position)
		if distance > mob.vision_range:
			#print("distance > mob.vision_range:")
			return Events.NONE
		
		# 1. represent the cos of the mob's angle of vision. 
		#    cos because the dot product of two direction vectors results in the cos of the angle between them.
		# 2. direction from the mob to the player.
		# 3. dot product between mob's ^ vector and direction to player = cos of angle between them
		# 	 (because there are normalised verctors)
		#    (Player is in front of mob -> result will be positive; Behind -> negative)
		#    (generally use dot product to check if node is in front or behind another. also use it for cones of vision, like here)
		var cos_max_angle_of_vision := cos(mob.vision_angle)
		var direction := mob.global_position.direction_to(BlackboardPlayer.player_global_position)
		var dot := mob.global_basis.z.dot(direction)
		
		# compare resulted dot product to our constant to check if player is in the mob's vision cone
		var player_in_vision_cone := dot > cos_max_angle_of_vision
		if player_in_vision_cone:
			#print("player_in_vision_cone")
			return Events.PLAYER_ENTERED_LINE_OF_SIGHT
		
		#print("return Events.NONE (end of update IDLE)")
		return Events.NONE

class StateLookAtPlayer extends State:
	var duration := 2.0
	var _time := 0.0
#
	func _init(init_mob: Mob3D) -> void:
		super("Look at Player", init_mob)
#
	func enter() -> void:
		_time = 0.0
		
	func update(delta: float) -> Events:
		_time += delta
		# We have a variable named duration that allows each mob to customize the duration of the state. 
		# The _time variable tracks the time elapsed since the start of the state. 
		# On enter, we reset the _time variable to zero. When the state times out, we return the FINISHED event.
		if _time >= duration:
			return Events.FINISHED

		var player_distance := mob.global_position.distance_to(
			BlackboardPlayer.player_global_position
		)
		if player_distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT
		#The BlackboardPlayer.player_global_position part is how we'll get a reference to the player character. 
		#It's a class that holds shared data between the mob and the states. 
		#We'll use it to get a reference to the player character without having to get the player node from the mobs.
		#It's called "blackboard" by tradition because it's a common term in AI programming. 
		#It's a shared memory space where you can store data that multiple AI agents can access.
		var direction := mob.global_position.direction_to(
			BlackboardPlayer.player_global_position
		)
		var target_rotation_y := Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
		mob.rotation.y = lerp_angle(mob.rotation.y, target_rotation_y, 2.0 * delta)
		return Events.NONE

class StateWait extends State:
	var duration := 0.5
	var _time := 0.0

	func _init(init_mob: Mob3D) -> void:
		super("Wait", init_mob)

	func enter() -> void:
		mob.skin.play("idle")
		_time = 0.0

	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		return Events.NONE

class StateFireProjectile extends State:
	# TODO: need projectile
	var spawning_point: Node3D = null
	var projectile_scene: PackedScene = null

	func _init(
		init_mob: Mob3D,
		init_spawning_point: Node3D,
		init_projectile_scene: PackedScene
	) -> void:
		super("Fire Projectile", init_mob)
		spawning_point = init_spawning_point
		projectile_scene = init_projectile_scene
	
	func enter() -> void:
		#var projectile: Projectile3D = projectile_scene.instantiate()
		#mob.add_sibling(projectile)

		#projectile.global_position = spawning_point.global_position
		#projectile.look_at(spawning_point.global_position + spawning_point.global_basis.z)
		# The main difference is the last instruction. 
		# It's a signal of the State class that the state can emit to indicate when it's done. 
		# The enter() method does not return an event to the state machine, so we use this signal instead.
		# (SM has an alternate way of triggering the FINISHED event; it connects to each state's finished signal in _transition()
		# This allows any state to emit FINISHED outside of the update() function.
		#finished.emit()
		pass

class StateChase extends State:
	var chase_speed := 3.0
	var drag_factor := 10.0
	var attack_range := 3.5
	
	func _init(init_mob: Mob3D) -> void:
		super("Chase", init_mob)

	func enter() -> void:
		# skin will only play animation if it exists, we can safely call it without checking
		mob.skin.play("chase")

	func update(delta: float) -> Events:
		## Like with player, function steers to a target position. 
		## Difference: uses the player's global position instead of an input direction.
		# We calculate the desired velocity. It's the mob going at full speed towards its target, the player.
		# We calculate the difference or distance between the current and desired velocities.
		# We interpolate the velocity towards the desired velocity by a fraction of the distance. 
		# Since our mob is an AI, we do it like this:
		#We get the player's global position from the blackboard.
		#We get the direction to the player; this is similar to getting the input direction for the player.
		#We calculate the desired velocity by multiplying the direction by the chase speed.
		#We calculate the distance between the current and desired velocities.
		#We use Vector3.move_toward() to move the velocity towards the desired velocity by a fraction of the distance. The fraction is the drag factor multiplied by delta.
		#The method Vector3.move_toward() moves the mob's velocity toward the desired velocity and ensures it can never overshoot. It's a useful function for steering behaviors as it greatly limits jitters and oscillations.
		var player_position := BlackboardPlayer.player_global_position
		var direction := mob.global_position.direction_to(player_position)
		var desired_velocity := (direction * chase_speed)
		var velocity_distance := mob.velocity.distance_to(desired_velocity)
		mob.velocity = mob.velocity.move_toward(
			desired_velocity,
			velocity_distance * drag_factor * delta
		)
		mob.velocity.y -= mob.gravity * delta
		mob.move_and_slide()
		
		# We got the direction from the mob to the player from before; we set the mob's rotation to face that direction. We also add PI to the angle to make the mob face the player correctly. You could alternatively use the mob's look_at() function. You can get the same result either way.
		mob.rotation.y = (
			Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
		)
		
		var distance := mob.global_position.distance_to(player_position)
		if distance < attack_range:
			return Events.PLAYER_ENTERED_ATTACK_RANGE
		elif distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT

		return Events.NONE

# In this implementation, I decided to make the state machine extend the Node type. 
# It gives the object direct access to _physics_process(), which allows it to update the current state. 
# It could also access the scene tree, create timers, and do other node manipulations if necessary.
class StateMachine extends Node:
	var transitions := {}: set = set_transitions
	var current_state: State

	func _ready() -> void:
		set_physics_process(false)

	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an Events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)

	func activate(initial_state: State = null) -> void:
		print("AI initial_state ", initial_state)
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		print("AI current_state.finished.connect", initial_state)
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)

	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		trigger_event(event)

	func trigger_event(event: Events) -> void:
		if not current_state in transitions:
			print("no current_state in transitions", current_state)
			return
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Events.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		var next_state = transitions[current_state][event]
		_transition(next_state)

	func _transition(new_state: State) -> void:
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		print("AI exiting ", current_state.name)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		print("AI entering ", current_state.name)

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[finished_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])

# From now on, you can access the player position from any state class by writing Blackboard.player_global_position, and it will always point to the same value.
class BlackboardPlayer extends RefCounted:
	# static means belongs to class, not its intance
	static var player_global_position := Vector3.ZERO
