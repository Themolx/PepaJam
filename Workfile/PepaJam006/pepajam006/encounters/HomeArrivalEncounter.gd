extends BaseEncounter

# Story data for this encounter
var encounter_title = "Finally Home"
var encounter_text = "You arrive at your front door, keys in hand. As you look back at the path you took, you realize that sometimes the journey home teaches you more about yourself than the destination ever could."

var encounter_choices = [
	{
		"text": "Start a new adventure",
		"next_scene": "res://encounters/PubExitEncounter.tscn"
	}
]

func _ready():
	encounter_id = "home_arrival"
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	scene_text.text = encounter_text
	left_button.text = encounter_choices[0].text
	right_button.visible = false  # Only one choice for ending

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	
	# Process effects if they exist
	if choice.has("effects"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.process_effects(choice.effects)
	
	# Load next scene (restart the game)
	if choice.has("next_scene"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.restart_game()

func on_encounter_start():
	# Peaceful ending atmosphere
	fade_background(1.0, 2.0)  # Bright and peaceful
	await get_tree().create_timer(1.0).timeout
	pulse_character(1.1, 3.0)  # Slow, peaceful pulse
