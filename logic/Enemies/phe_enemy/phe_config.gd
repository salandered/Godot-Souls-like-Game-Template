@tool
@icon("res://-assets-/x_icons/white/icon_gear.png")
extends Node
class_name PHEConfig

var me: PHCharacter


func TOO_FAR() -> float:
	var _r := PHEStaticConfig.TOO_FAR
	if me.angry_raised:
		_r += 4.0
	return _r

func REAL_FAR() -> float:
	var _r := PHEStaticConfig.REAL_FAR
	if me.angry_raised:
		_r += 3.0
	return _r

func GAP_CLOSER_RAD() -> float:
	var _r := PHEStaticConfig.GAP_CLOSER_RAD
	if me.angry_raised:
		_r += -1.0
	return _r

func CLOSE_TO_ORBIT() -> float:
	var _r := PHEStaticConfig.CLOSE_TO_ORBIT
	if me.angry_raised:
		_r += 2.0
	return _r

func ORBIT_RAD() -> float:
	var _r := PHEStaticConfig.ORBIT_RAD
	if me.angry_raised:
		_r += -2.0
	return _r

func DODGE_RAD() -> float:
	var _r := PHEStaticConfig.DODGE_RAD
	if me.angry_raised:
		_r += 0.5
	return _r

func COMBAT_RAD() -> float:
	var _r := PHEStaticConfig.COMBAT_RAD
	if me.angry_raised:
		_r += 0.4
	return _r

func TOO_CLOSE() -> float:
	var _r := PHEStaticConfig.TOO_CLOSE
	if me.angry_raised:
		_r += 0.2
	return _r

func CLOSEST() -> float:
	var _r := PHEStaticConfig.CLOSEST
	if me.angry_raised:
		_r += 0.0
	return _r


##

const DEFAULT_Y_OFFSET: float = -0.115
const DEF_COMMITMENT: float = 0.25
const DEF_FATIGUE: float = 20.0
