class_name BackgroundMusicSystem
extends NodeLogger

@export_group("Configuration")
@export var music_tracks: Array[AudioStream]
@export var first_track_to_play_idx: int = -1
@export var base_volume_db: float = -10.0
@export var fade_duration: float = 10.0

@export_group("Delays")
@export var min_wait_time: float = 15.0
@export var max_wait_time: float = 40.0
## Chance (0.0 to 1.0) to wait only 1 second instead of the full range
@export var quick_transition_chance: float = 0.3


var bus_name: = BusID.GAME_MUSIC

var _music_asp: AudioStreamPlayer
var _fade_tween: Tween
var _gap_timer: Timer

var _track_bag: ShuffleBag


func _ready() -> void:
	_music_asp = AudioStreamPlayer.new()
	_music_asp.bus = bus_name
	add_child(_music_asp)
	
	_gap_timer = Timer.new()
	_gap_timer.one_shot = true
	_gap_timer.timeout.connect(_on_gap_finished)
	add_child(_gap_timer)
	
	_track_bag = ShuffleBag.new(music_tracks, true)

	__log_("System Ready", "Tracks:", music_tracks.size(), "Bus:", bus_name)

	if music_tracks.size() > 0:
		_play_next_bag_track(false, first_track_to_play_idx)
	else:
		__log_warn_soft("No music tracks assigned!")


# PUBLIC API
# region

## Interrupts the current music with a smooth crossfade.
## - transition_duration: Time to fade out old / fade in new (e.g., 2.0s out, 2.0s in).
func play_priority_track(
	stream: AudioStream,
	volume_override: float = base_volume_db,
	from_position: float = 0.0,
	transition_duration: float = 2.0
) -> void:
	if not stream:
		__log_error("play_priority_track called with null stream")
		return

	__log_("! Priority Track (Fade) !", stream.resource_path.get_file())
	
	# Stop the 'gap' timer so we don't accidentally start a random track
	_gap_timer.stop()
	
	# Kill any running fade tweens (stops the previous track from fading out on its own)
	if _fade_tween: _fade_tween.kill()
	
	_fade_tween = create_tween()
	
	# Fade Out Current (only if playing)
	if _music_asp.playing:
		# Fade to silence
		_fade_tween.tween_property(_music_asp, PropC.VOLUME_DB, -80.0, transition_duration)
	
	# Swap Stream & Start Playing (Silent)
	_fade_tween.tween_callback(func():
		_music_asp.stop()
		_music_asp.stream = stream
		_music_asp.volume_db = -80.0 # Start at silence
		_music_asp.play(from_position)
	)
	
	# Fade In New Track
	_fade_tween.tween_property(_music_asp, PropC.VOLUME_DB, volume_override, transition_duration)
	
	# Schedule the "End of Track" Fade
	# We run this in a callback because we need the track to be playing to get correct positions
	_fade_tween.tween_callback(func():
		_schedule_end_of_track_fade(stream)
	)


## Helper to schedule the fade-out at the end of the song
func _schedule_end_of_track_fade(stream: AudioStream) -> void:
	var track_len = stream.get_length()
	var current_pos = _music_asp.get_playback_position()
	
	# Calculate how long to wait before starting the end fade
	# Logic: Total Length - Fade Duration - Time already elapsed
	var time_until_fade = maxf(0.0, track_len - fade_duration - current_pos)
	
	# Start a new tween specifically for the end of the track
	if _fade_tween: _fade_tween.kill()
	_fade_tween = create_tween()
	
	_fade_tween.tween_interval(time_until_fade)
	_fade_tween.tween_property(_music_asp, PropC.VOLUME_DB, -80.0, fade_duration)
	_fade_tween.tween_callback(_on_track_fade_complete)

# endregion


# INTERNAL LOGIC
# region

## Picks the next track from the bag and plays it
func _play_next_bag_track(is_random: bool = true, first_track_to_play_idx_: int = -1) -> void:
	var track := _select_track(is_random, first_track_to_play_idx_)
	
	if not track:
		__log_error("Failed to select track from bag", "returning")
		return

	_play_stream(track, base_volume_db)


## Core function to play ANY stream with the standard fade-out logic
func _play_stream(track: AudioStream, vol_db: float, from_position: float = 0.0) -> void:
	# reset state
	_music_asp.stop()
	if _fade_tween: _fade_tween.kill()
	_gap_timer.stop()
	
	# setup Player
	_music_asp.stream = track
	_music_asp.volume_db = vol_db
	_music_asp.play(from_position)
	
	# fade timings
	var track_length := track.get_length()
	var time_until_fade := maxf(0.0, track_length - fade_duration)
	
	__log_("Playing stream", track.resource_path.get_file(),
		"Length:", "%.1fs" % track_length,
		"FadeIn:", "%.1fs" % time_until_fade)
	
	# setup fade sequence
	_fade_tween = create_tween()
	_fade_tween.tween_interval(time_until_fade)
	_fade_tween.tween_property(_music_asp, PropC.VOLUME_DB, -80.0, fade_duration)
	_fade_tween.tween_callback(_on_track_fade_complete)


func _select_track(is_random: bool = true, first_track_to_play_idx_: int = -1) -> AudioStream:
	if is_random:
		return _track_bag.pick()
	else:
		return _track_bag.pick_specific(first_track_to_play_idx_)


func _on_track_fade_complete() -> void:
	_music_asp.stop()
	
	var wait_time: float
	var is_quick: bool = false
	
	if randf() < quick_transition_chance:
		wait_time = 1.0
		is_quick = true
	else:
		wait_time = randf_range(min_wait_time, max_wait_time)
		
	__log_("Track finished", "Wait time:", "%.1fs" % wait_time, "Quick:", is_quick)
		
	_gap_timer.start(wait_time)


func _on_gap_finished() -> void:
	__log_("Gap finished, returning to bag shuffle...")
	_play_next_bag_track()

# endregion

## __LOGS
# region

func pp_name() -> String:
	return "🎶BackgroundMusicSys"

func __LOG_B() -> bool:
	return true

# endregion
