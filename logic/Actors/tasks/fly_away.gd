extends BTAction

var timer := 0.0
const FLY_DUR = 2.0
var dir: int

# called one time
func _enter():
	dir = [-1,1].pick_random() # left or right 
	
func _tick(delta: float) -> Status:
	agent.fly_away(delta, dir)
	
	timer += delta
	if timer >= FLY_DUR:
		timer = 0.0
		agent.queue_free() # bird DELETES itself 
		return SUCCESS
	
	return RUNNING
