class_name MobSkeleton3D extends Mob3D # Mob3D extends from Character

func _ready() -> void:
	print("MobSkeleton3D _ready ")
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)
	
	var idle := AI.StateIdle.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	
	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		},
	}
	print("AI state_machine.activate ")
	state_machine.activate(idle)
	
	#state_machine.is_debugging = true
