extends RefCounted
## Legs Action Motion Type
class_name MotionType

const IDLE = 'IDLE'
const START = 'START'
const LOOP = 'LOOP'
const STOP = 'STOP'


static func get_all_types() -> Array:
	return [IDLE, START, LOOP, STOP]
