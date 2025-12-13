extends BaseRefCountedLogger
class_name ASPConfig


## increase or decrease of vol db. usually like -3 or +3
var vol_db_change: float
## increase or decrease of pitch (base pitch is always 1.0). usually like -0.2 or +0.2
var pitch_change: float
##
var unit_size: float
## has effect if > 0.0
var max_distance: float
##
var max_polyphony: int
##
var panning_strength: float
var max_db: float
##
var bus_id: String
## may be null. client code should handle nulls
var stream: AudioStream


var _min_max_vol_db_change: FMinMax = FMinMax.new(-80.0, 15.0)
var _min_max_pitch_change: FMinMax = FMinMax.new(-0.7, 0.7)
var _min_max_unit_size: FMinMax = FMinMax.new(0.1, 100.0)
var _min_max_max_distance: FMinMax = FMinMax.new(0.0, 4096.0 / 4.0)
var _min_max_max_polyphony: FMinMax = FMinMax.new(1, 16)
var _min_max_panning_strength: FMinMax = FMinMax.new(0.0, 3.0)
var _min_max_max_db: FMinMax = FMinMax.new(-1.0, 4.0)


var DEF_VOL_DB_CHANGE: float = 0.0
var DEF_PITCH_CHANGE: float = 0.0
var DEF_UNIT_SIZE: float = 5.0
var DEF_MAX_DISTANCE: float = 20.0
var DEF_MAX_POLYPHONY: int = 4
var DEF_PANNING_STRENGTH: float = 0.5
var DEF_BUS_ID: String = Constants.SFX_ASP_BASE_BUS_ID


## use INF to apply defaults
func _init(
	vol_db_change_: float = INF,
	pitch_change_: float = INF,
	unit_size_: float = INF,
	max_distance_: float = INF,
	max_polyphony_: int = -1,
	panning_strength_: float = INF,
	bus_id_: String = "",
	stream_: AudioStream = null,
):
	if vol_db_change_ == INF:
		vol_db_change_ = DEF_VOL_DB_CHANGE
	if pitch_change_ == INF:
		pitch_change_ = DEF_PITCH_CHANGE
	if unit_size_ == INF:
		unit_size_ = DEF_UNIT_SIZE
	if max_distance_ == INF:
		max_distance_ = DEF_MAX_DISTANCE
	if max_polyphony_ == -1:
		max_polyphony_ = DEF_MAX_POLYPHONY
	if panning_strength_ == INF:
		panning_strength_ = DEF_PANNING_STRENGTH
	if bus_id_ == "":
		bus_id_ = DEF_BUS_ID

	self.vol_db_change = vol_db_change_
	self.pitch_change = pitch_change_
	self.unit_size = unit_size_
	self.max_distance = max_distance_
	self.max_polyphony = max_polyphony_
	self.panning_strength = panning_strength_
	self.bus_id = bus_id_
	
	self.stream = stream_

	_validate()


func _validate() -> void:
	_min_max_vol_db_change.clamp(vol_db_change, true, "vol_db_change")
	_min_max_pitch_change.clamp(pitch_change, true, "pitch_change")
	_min_max_unit_size.clamp(unit_size, true, "unit_size")
	_min_max_max_distance.clamp(max_distance, true, "max_distance")
	_min_max_max_polyphony.clamp(max_polyphony, true, "max_polyphony")
	_min_max_panning_strength.clamp(panning_strength, true, "panning_strength")

	if bus_id == "":
		bus_id = DEF_BUS_ID
	if not AudioBusUtil.bus_exists(bus_id):
		__log_warn_soft(pp.s("bus_id is unknown, using default", "provided/default", bus_id, DEF_BUS_ID))
		bus_id = DEF_BUS_ID

func _to_string() -> String:
	return pp.s("Vol/Pitch changes", vol_db_change, pitch_change,
		"UnitSz/MaxDist/MaxPolyph/PanningStr", unit_size, max_distance, max_polyphony, panning_strength,
		pp.bus_id(bus_id), "Stream", str(stream) if stream else "[-]")


func set_up_asp(some_asp: AudioStreamPlayer3D) -> AudioStreamPlayer3D:
	some_asp.volume_db = Constants.SFX_ASP_BASE_VOL_DB
	some_asp.volume_db += vol_db_change

	some_asp.pitch_scale = 1.0
	some_asp.pitch_scale += pitch_change

	some_asp.unit_size = unit_size
	some_asp.max_distance = max_distance
	some_asp.max_polyphony = max_polyphony
	some_asp.panning_strength = panning_strength

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


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
