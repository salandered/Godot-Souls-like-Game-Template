class_name M_GameState
extends Resource

const STATE_NAME: String = "M_GameState"
const FILE_PATH = "res://ui/game_state/m_game_state.gd"

@export var level_states: Dictionary = {}
@export var current_level_path: String
@export var continue_level_path: String
@export var times_played: int

# A Resource that manages and persists the player's overall game progress.
#
# This class acts as a static manager for all game-related save data. It does not
# handle the saving and loading to disk itself, but instead relies on M_GlobalState singleton 
# to store its own state as a persistent resource.
#
## Responsibilities:
# - Tracks which levels have been reached and stores their individual states ([LevelState]).
# - Remembers the last level played for the 'Continue' functionality.
# - Manages the path for the next level to be loaded by the M_SceneLoader.
# - Provides a method to reset all game progress to a fresh state.

static func get_level_state(level_state_key: String) -> M_LevelState:
	if not has_game_state():
		return
	var game_state := get_or_create_state()
	if level_state_key.is_empty(): return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key]
	else:
		var new_level_state := M_LevelState.new()
		game_state.level_states[level_state_key] = new_level_state
		M_GlobalState.save()
		return new_level_state


static func has_game_state() -> bool:
	return M_GlobalState.has_state(STATE_NAME)


static func get_or_create_state() -> M_GameState:
	return M_GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)


static func get_current_level_path() -> String:
	if not has_game_state():
		return ""
	var game_state := get_or_create_state()
	return game_state.current_level_path


static func set_current_level(level_path: String) -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = level_path
	M_GlobalState.save()


static func start_game() -> void:
	M_GlobalState.save()


static func continue_game() -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = game_state.continue_level_path
	M_GlobalState.save()


static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.level_states = {}
	game_state.current_level_path = ""
	game_state.continue_level_path = ""
	M_GlobalState.save()
