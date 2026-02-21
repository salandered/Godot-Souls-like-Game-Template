extends BaseASPConfig
class_name ASP3DConfig


##
var unit_size: float
## has effect if > 0.0
var max_distance: float
##
var panning_strength: float

# TODO: var max_db: float 


var _min_max_unit_size: FMinMax = FMinMax.new(0.1, 100.0)
var _min_max_max_distance: FMinMax = FMinMax.new(0.0, 4096.0 / 4.0)
var _min_max_panning_strength: FMinMax = FMinMax.new(0.0, 3.0)


const DEF_UNIT_SIZE: float = 5.0
const DEF_MAX_DISTANCE: float = 20.0
const DEF_PANNING_STRENGTH: float = 0.5

## Template to quickly initialise new config
# var asp_config := ASP3DConfig.new(
# 	ASP3DConfig.DEF_VOL_DB_CHANGE,
# 	ASP3DConfig.DEF_PITCH_CHANGE,
# 	ASP3DConfig.DEF_UNIT_SIZE,
# 	ASP3DConfig.DEF_MAX_DISTANCE,
# 	ASP3DConfig.DEF_MAX_POLYPHONY,
# 	ASP3DConfig.DEF_PANNING_STRENGTH,
# 	ASP3DConfig.DEF_BUS_ID,
# 	null)


## exactly this order in _init (legacy reasons)
func _init(
	vol_db_change_: float = DEF_VOL_DB_CHANGE,
	pitch_change_: float = DEF_PITCH_CHANGE,
	unit_size_: float = DEF_UNIT_SIZE,
	max_distance_: float = DEF_MAX_DISTANCE,
	max_polyphony_: int = DEF_MAX_POLYPHONY,
	panning_strength_: float = DEF_PANNING_STRENGTH,
	bus_id_: StringName = DEF_BUS_ID,
	stream_: AudioStream = null,
	from_position_: float = 0.0

):
	self.unit_size = unit_size_
	self.max_distance = max_distance_
	self.panning_strength = panning_strength_

	super._init(vol_db_change_, pitch_change_, max_polyphony_, bus_id_, stream_, from_position_)


func _validate_implementation() -> void:
	_min_max_unit_size.clamp(unit_size, true, "unit_size")
	_min_max_max_distance.clamp(max_distance, true, "max_distance")
	_min_max_panning_strength.clamp(panning_strength, true, "panning_strength")


func _to_string() -> String:
	return pp.s("Vol/Pitch changes", vol_db_change, pitch_change,
		"UnitSz/MaxDist/MaxPolyph/PanningStr", unit_size, max_distance, max_polyphony, panning_strength,
		pp.bus_id(bus_id), "Stream", str(stream) if stream else "[-]", "from_pos", from_position)


func set_up_asp(some_asp: AudioStreamPlayer3D) -> AudioStreamPlayer3D:
	if not some_asp: return null
	
	some_asp.volume_db = Constants.SFX_ASP_BASE_VOL_DB
	some_asp.volume_db += vol_db_change

	some_asp.pitch_scale = 1.0
	some_asp.pitch_scale += pitch_change

	some_asp.unit_size = unit_size
	some_asp.max_distance = max_distance
	some_asp.max_polyphony = max_polyphony
	some_asp.panning_strength = panning_strength
	
	## NOTE
	some_asp.max_db = -2.0

	some_asp.bus = bus_id

	## prevents erasing stream if config's stream is null and some_asp's already has its own
	if stream:
		some_asp.stream = stream
	

	return some_asp


## A BIT OF TRIVIA


# region: AUDIO SETTINGS PRESETS

## -- BIG ENEMY (Troll/Mech/Golem) --
## Goal: Sound heavy, "physically" wide, and carries over long distances.
# Unit Size:       4.0 - 5.0   (Radius of Full Volume. Makes the source feel physically large/wide)
# Max Distance:    60.0 m      (Big things are loud; hear them from far away)
# Pitch Scale:     0.6 - 0.8   (Lowers pitch to add "weight" and mass)
# Panning Str:     0.5 - 0.7   (Reduced panning lets sound bleed into both ears, feeling "wider")
# Volume dB:       +2.0 dB     (Should act as the "bass" of the combat mix)
# Max Polyphony:   2 - 3       (Ensures heavy impact tails don't cut each other off)

## -- MAIN PLAYER (Self) --
## Goal: Clear, centered, and non-fatiguing for the user.
# Unit Size:       1.0         (Standard human size)
# Max Distance:    30.0 m      (Standard)
# Pitch Scale:     0.95 - 1.05 (Randomize slightly for natural feel)
# Panning Str:     0.2 - 0.5   (NOTE: Low panning keeps your own feet centered in stereo mix)
# Volume dB:       -4.0 dB     (Quieter than enemies to avoid ear fatigue)
# Max Polyphony:   2 - 3       (Prevents "choppy" robotic steps; lets reverb tails fade naturally)

## NOTE ON UNIT SIZE:
## Think of Unit Size as the "Radius of Full Volume".
## Distance < Unit Size = 100% Volume (0 attenuation).
## Distance > Unit Size = Volume starts dropping.

# endregion

# region: WEAPON AUDIO PRESETS

## -- STANDARD SWORD (Katana/Longsword) --
## Goal: Sharp, fast, and precise. Needs to cut through the mix without being muddy.
# Unit Size:       0.5 - 1.0   (Thin blade; sound source is concentrated)
# Max Distance:    20.0 m      (Don't need to hear a dagger swing from across the map)
# Pitch Scale:     1.0 - 1.2   (Higher pitch emphasizes sharpness and speed)
# Panning Str:     0.3 - 0.5   (Narrow panning keeps the "swoosh" focused in front of player)
# Volume dB:       -5.0 dB     (Sharp transients cut through mix easily; doesn't need raw volume)
# Max Polyphony:   4 - 6       (Crucial for rapid combos so "swing 1" tail isn't cut by "swing 2")

## -- HEAVY WEAPON (Greatsword/Hammer) --
## Goal: Heavy, displacing air, intimidating.
# Unit Size:       2.0 - 3.0   (Moves a lot of air; feels physically wider)
# Max Distance:    35.0 m      (Impacts and whooshes should carry further)
# Pitch Scale:     0.7 - 0.9   (Lower pitch adds weight/mass to the swing)
# Panning Str:     0.5 - 0.7   (Wider panning follows the wide arc of the swing across stereo field)
# Volume dB:       -1.0 dB     (Needs to be loud to sell the impact)
# Max Polyphony:   3 - 4       (Slower swings mean less overlap, but still need tail space)

# endregion

# region: SURFACE MATERIAL PRESETS

## -- CONCRETE / STONE (The Baseline) --
## Goal: Sharp, clear, and reflective. Acts as the "Standard" 0.0 value.
# Volume Mod:      0.0 dB      (Baseline reference)
# Pitch Mod:       1.0         (Standard speed)
# Characteristics: High frequency "clip-clop" transients. Cleanest sound for sync checks.

## -- WOOD (Hollow/Resonant) --
## Goal: Warm, "thumpy", slightly louder due to resonance.
# Volume Mod:      +2.0 dB     (Wood floors resonate; often perceived as louder/bassier)
# Pitch Mod:       0.9 - 0.95  (Lower pitch emphasizes the hollow space underneath)
# Characteristics: Needs good bass response; avoid making it sound like plastic.

## -- DIRT / GRASS (Soft/Absorbent) --
## Goal: Muffled, crunchy, organic.
# Volume Mod:      -4.0 dB     (Soft ground absorbs sound energy; naturally quieter)
# Pitch Mod:       0.8 - 0.9   (Duller sound; high frequencies are absorbed)
# Characteristics: "Crunchy" texture. High randomization needed to hide repetition.

## -- METAL (Grating/Harsh) --
## Goal: Bright, sharp, industrial.
# Volume Mod:      -2.0 dB     (Metal is loud, but high frequencies pierce easily, so mix it slightly lower to save ears)
# Pitch Mod:       1.1 - 1.2   (Higher pitch emphasizes rigidity and "ping")
# Characteristics: Often needs a slight reverb tail or "ring" in the sample itself.

## -- WATER / MUD (Liquid/Viscous) --
## Goal: Wet, squishy, splashing.
# Volume Mod:      +1.0 dB     (Splashes are dynamic and noisy)
# Pitch Mod:       0.9 - 1.1   (HIGH RANDOMIZATION varies the "splash" size feeling)
# Characteristics: Requires the most variety/randomness to avoid the "same puddle" effect.

# endregion
