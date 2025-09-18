extends Node
class_name TraitsContainer
@onready var me: SECharacter = $".."

var strength: Trait
var speed: Trait
var endurance: Trait
var vigilance: Trait
var aggression: Trait
var curiosity: Trait
var weirdness: Trait
var peaceful: Trait

func accept_traits():
	strength = Trait.new(
		me.raw_traits_resource.STRENGTH,
		me.raw_traits_resource.strength,
		me.raw_traits_resource.strength_min,
		me.raw_traits_resource.strength_max,
		me.raw_traits_resource.strength_step,
		me.raw_traits_resource.strength_default
	)
	speed = Trait.new(
		me.raw_traits_resource.SPEED,
		me.raw_traits_resource.speed,
		me.raw_traits_resource.speed_min,
		me.raw_traits_resource.speed_max,
		me.raw_traits_resource.speed_step,
		me.raw_traits_resource.speed_default
	)
	endurance = Trait.new(
		me.raw_traits_resource.ENDURANCE,
		me.raw_traits_resource.endurance,
		me.raw_traits_resource.endurance_min,
		me.raw_traits_resource.endurance_max,
		me.raw_traits_resource.endurance_step,
		me.raw_traits_resource.endurance_default
	)
	vigilance = Trait.new(
		me.raw_traits_resource.VIGILANCE,
		me.raw_traits_resource.vigilance,
		me.raw_traits_resource.vigilance_min,
		me.raw_traits_resource.vigilance_max,
		me.raw_traits_resource.vigilance_step,
		me.raw_traits_resource.vigilance_default
	)
	aggression = Trait.new(
		me.raw_traits_resource.AGGRESSION,
		me.raw_traits_resource.aggression,
		me.raw_traits_resource.aggression_min,
		me.raw_traits_resource.aggression_max,
		me.raw_traits_resource.aggression_step,
		me.raw_traits_resource.aggression_default
	)
	curiosity = Trait.new(
		me.raw_traits_resource.CURIOSITY,
		me.raw_traits_resource.curiosity,
		me.raw_traits_resource.curiosity_min,
		me.raw_traits_resource.curiosity_max,
		me.raw_traits_resource.curiosity_step,
		me.raw_traits_resource.curiosity_default
	)
	weirdness = Trait.new(
		me.raw_traits_resource.WEIRDNESS,
		me.raw_traits_resource.weirdness,
		me.raw_traits_resource.weirdness_min,
		me.raw_traits_resource.weirdness_max,
		me.raw_traits_resource.weirdness_step,
		me.raw_traits_resource.weirdness_default
	)
	peaceful = Trait.new(
		me.raw_traits_resource.PEACEFUL,
		me.raw_traits_resource.peaceful,
		me.raw_traits_resource.peaceful_min,
		me.raw_traits_resource.peaceful_max,
		me.raw_traits_resource.peaceful_step,
		me.raw_traits_resource.peaceful_default
	)
