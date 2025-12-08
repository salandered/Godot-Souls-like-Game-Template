extends Resource
class_name EnemyTraitsResource

# ——— Trait data grouped per trait ———
# -- this is horrible but won't be changing --

##"Raw physical power" 
##Tendency to attack" 
## i"Movement speed multiplier" 
## i"How alert the AI is" 
##"Stamina pool" 
##"Willingness to explore" 
## i"Random behavior factor" 
## i"Tendency to flee vs fight" 


# STRENGTH
const STRENGTH := "strength"
const strength_min := 1
const strength_max := 10
const strength_step := 1
const strength_default := 2

# AGGRESSION
const AGGRESSION := "aggression"
const aggression_min := 1
const aggression_max := 10
const aggression_step := 1
const aggression_default := aggression_min

# SPEED
const SPEED := "speed"
const speed_min := 0.1
const speed_max := 2.0
const speed_step := 0.1
const speed_default := 1

# VIGILANCE
const VIGILANCE := "vigilance"
const vigilance_min := 0.1
const vigilance_max := 2.0
const vigilance_step := 0.1
const vigilance_default := 1

# ENDURANCE
const ENDURANCE := "endurance"
const endurance_min := 1
const endurance_max := 10
const endurance_step := 1
const endurance_default := 4

# CURIOSITY
const CURIOSITY := "curiosity"
const curiosity_min := 1
const curiosity_max := 10
const curiosity_step := 1
const curiosity_default := 2

# WEIRDNESS
const WEIRDNESS := "weirdness"
const weirdness_min := 0
const weirdness_max := 5
const weirdness_step := 1
const weirdness_default := 0

# PEACEFUL
const PEACEFUL := "peaceful"
const peaceful_min := 0
const peaceful_max := 5
const peaceful_step := 1
const peaceful_default := 0


# ——— Inspector sliders  ———

@export_group("Basic Stats")
@export_range(strength_min, strength_max, strength_step)
var strength: int = strength_default

@export_range(speed_min, speed_max, speed_step)
var speed: float = speed_default

@export_range(endurance_min, endurance_max, endurance_step)
var endurance: int = endurance_default

@export_range(vigilance_min, vigilance_max, vigilance_step)
var vigilance: float = vigilance_default


@export_group("Behavior Traits")
@export_range(aggression_min, aggression_max, aggression_step)
var aggression: int = aggression_default

@export_range(curiosity_min, curiosity_max, curiosity_step)
var curiosity: int = curiosity_default


@export_group("Personality")
@export_range(weirdness_min, weirdness_max, weirdness_step)
var weirdness: int = weirdness_default

@export_range(peaceful_min, peaceful_max, peaceful_step)
var peaceful: int = peaceful_default
