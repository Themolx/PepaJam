extends Node
class_name StoryManager

signal encounter_load_requested(encounter_scene_path: String)
signal cutscene_triggered(cutscene_data: Dictionary)

# Global game state
var unlocked_paths: Array[String] = []
var story_flags: Dictionary = {}
var current_act: int = 1

func _ready():
	print("StoryManager initialized - managing global flags and unlocks")

func load_encounter(encounter_path: String):
	"""Load a specific encounter by its scene path"""
	encounter_load_requested.emit(encounter_path)

func trigger_cutscene(cutscene_data: Dictionary):
	"""Trigger a cutscene with the given data"""
	cutscene_triggered.emit(cutscene_data)

# Global state management functions
func unlock_path(path: String):
	"""Unlock a story path"""
	if not unlocked_paths.has(path):
		unlocked_paths.append(path)
		print("Unlocked path: ", path)

func lock_path(path: String):
	"""Lock a story path"""
	if unlocked_paths.has(path):
		unlocked_paths.erase(path)
		print("Locked path: ", path)

func is_path_unlocked(path: String) -> bool:
	"""Check if a path is unlocked"""
	return unlocked_paths.has(path)

func set_flag(flag_name: String, value):
	"""Set a story flag"""
	story_flags[flag_name] = value
	print("Set flag: ", flag_name, " = ", value)

func get_flag(flag_name: String, default_value = null):
	"""Get a story flag value"""
	return story_flags.get(flag_name, default_value)

func has_flag(flag_name: String) -> bool:
	"""Check if a flag exists"""
	return story_flags.has(flag_name)

func process_effects(effects: Dictionary):
	"""Process choice effects (unlock paths, set flags, etc.)"""
	if effects.has("unlock_paths"):
		for path in effects.unlock_paths:
			unlock_path(path)
	
	if effects.has("lock_paths"):
		for path in effects.lock_paths:
			lock_path(path)
	
	if effects.has("set_flags"):
		for flag_name in effects.set_flags:
			set_flag(flag_name, effects.set_flags[flag_name])
	
	if effects.has("cutscene"):
		trigger_cutscene(effects.cutscene)

func restart_game():
	"""Reset all global state and start from beginning"""
	current_act = 1
	unlocked_paths.clear()
	story_flags.clear()
	print("Game restarted - all flags and paths cleared")
	# Load starting encounter
	load_encounter("res://encounters/PubExitEncounter.tscn")
