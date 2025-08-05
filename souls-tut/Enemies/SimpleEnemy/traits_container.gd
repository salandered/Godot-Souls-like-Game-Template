extends Node
class_name TraitsContainer
@onready var me: SECharacter = $".."

var _strength: Trait
var _speed: Trait
var _endurance: Trait
var _vigilance: Trait
var _aggression: Trait
var _curiosity: Trait
var _weirdness: Trait
var _peaceful: Trait

var strength:
	get:
		return _strength.value
var speed:
	get:
		return _speed.value
var endurance:
	get:
		return _endurance.value
var vigilance:
	get:
		return _vigilance.value
var aggression:
	get:
		return _aggression.value
var curiosity:
	get:
		return _curiosity.value
var weirdness:
	get:
		return _weirdness.value
var peaceful:
	get:
		return _peaceful.value


func accept_traits():
	_strength = Trait.new(
		me.raw_traits_resource.STRENGTH,
		me.raw_traits_resource.strength,
		me.raw_traits_resource.strength_min,
		me.raw_traits_resource.strength_max,
		me.raw_traits_resource.strength_step,
		me.raw_traits_resource.strength_default
	)
	_speed = Trait.new(
		me.raw_traits_resource.SPEED,
		me.raw_traits_resource.speed,
		me.raw_traits_resource.speed_min,
		me.raw_traits_resource.speed_max,
		me.raw_traits_resource.speed_step,
		me.raw_traits_resource.speed_default
	)
	_endurance = Trait.new(
		me.raw_traits_resource.ENDURANCE,
		me.raw_traits_resource.endurance,
		me.raw_traits_resource.endurance_min,
		me.raw_traits_resource.endurance_max,
		me.raw_traits_resource.endurance_step,
		me.raw_traits_resource.endurance_default
	)
	_vigilance = Trait.new(
		me.raw_traits_resource.VIGILANCE,
		me.raw_traits_resource.vigilance,
		me.raw_traits_resource.vigilance_min,
		me.raw_traits_resource.vigilance_max,
		me.raw_traits_resource.vigilance_step,
		me.raw_traits_resource.vigilance_default
	)
	_aggression = Trait.new(
		me.raw_traits_resource.AGGRESSION,
		me.raw_traits_resource.aggression,
		me.raw_traits_resource.aggression_min,
		me.raw_traits_resource.aggression_max,
		me.raw_traits_resource.aggression_step,
		me.raw_traits_resource.aggression_default
	)
	_curiosity = Trait.new(
		me.raw_traits_resource.CURIOSITY,
		me.raw_traits_resource.curiosity,
		me.raw_traits_resource.curiosity_min,
		me.raw_traits_resource.curiosity_max,
		me.raw_traits_resource.curiosity_step,
		me.raw_traits_resource.curiosity_default
	)
	_weirdness = Trait.new(
		me.raw_traits_resource.WEIRDNESS,
		me.raw_traits_resource.weirdness,
		me.raw_traits_resource.weirdness_min,
		me.raw_traits_resource.weirdness_max,
		me.raw_traits_resource.weirdness_step,
		me.raw_traits_resource.weirdness_default
	)
	_peaceful = Trait.new(
		me.raw_traits_resource.PEACEFUL,
		me.raw_traits_resource.peaceful,
		me.raw_traits_resource.peaceful_min,
		me.raw_traits_resource.peaceful_max,
		me.raw_traits_resource.peaceful_step,
		me.raw_traits_resource.peaceful_default
	)
