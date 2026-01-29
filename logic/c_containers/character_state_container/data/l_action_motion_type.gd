## Legs Action Motion Type
class_name MotionType
extends RefCounted


const IDLE := 'IDLE'
const START := 'START'
const LOOP := 'LOOP'
const STOP := 'STOP'


static func get_all_types() -> Array[String]:
	return [IDLE, START, LOOP, STOP]
