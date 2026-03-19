class_name BGConfig
extends PHEConfig


## DIST TO PLAYER
@export var TOO_FAR_: float = 28.0
@export var REAL_FAR_: float = 14.0
@export var GAP_CLOSER_RAD_: float = 7.5
@export var CLOSE_TO_ORBIT_: float = 8.0
@export var ORBIT_RAD_: float = 6.0
@export var DODGE_RAD_: float = 4.5
@export var CLOSEST_: float = 0.95

## 
@export var DIST_TO_AWAKE: float = 4.5


## 

@export var me: PHCharacter

##


func TOO_FAR() -> float:
	var _r := TOO_FAR_
	if me.angry_raised:
		_r += 4.0
	return _r

func REAL_FAR() -> float:
	var _r := REAL_FAR_
	if me.angry_raised:
		_r += 3.0
	return _r

func GAP_CLOSER_RAD() -> float:
	var _r := GAP_CLOSER_RAD_
	if me.angry_raised:
		_r += -1.0
	return _r

func CLOSE_TO_ORBIT() -> float:
	var _r := CLOSE_TO_ORBIT_
	if me.angry_raised:
		_r += 2.0
	return _r

func ORBIT_RAD() -> float:
	var _r := ORBIT_RAD_
	if me.angry_raised:
		_r += -2.0
	return _r

func DODGE_RAD() -> float:
	var _r := DODGE_RAD_
	if me.angry_raised:
		_r += 0.5
	return _r

func COMBAT_RAD() -> float:
	var _r := COMBAT_RAD_
	if me.angry_raised:
		_r += 0.4
	return _r

func TOO_CLOSE() -> float:
	var _r := TOO_CLOSE_
	if me.angry_raised:
		_r += 0.2
	return _r

func CLOSEST() -> float:
	var _r := CLOSEST_
	if me.angry_raised:
		_r += 0.0
	return _r
