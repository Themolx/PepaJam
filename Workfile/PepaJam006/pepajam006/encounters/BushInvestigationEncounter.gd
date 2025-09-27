extends BaseEncounter

# Story data for this encounter
var encounter_title = "The Mystery Revealed"
var encounter_text = "You push through the bushes and find... a very confused hedgehog wearing a tiny hat! It looks at you judgmentally before waddling away. You feel oddly proud of your detective skills."

var encounter_choices = [
	{
		"text": "Follow the hedgehog",
		"next_scene": "res://encounters/HedgehogAdventureEncounter.tscn",
		"effects": {
			"unlock_paths": ["animal_friend_path"]
		}
	},
	{
		"text": "Continue through the park",
		"next_scene": "res://encounters/ParkPathEncounter.tscn"
	}
]

func _ready():
	encounter_id = "bush_investigation"
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	scene_text.text = encounter_text
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text

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
	
	# Load next scene
	if choice.has("next_scene"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.load_encounter(choice.next_scene)

func on_encounter_start():
	# Mystery discovery animation
	shake_character(3.0, 0.5)
	await get_tree().create_timer(1.0).timeout
	pulse_character(1.3, 1.0)
