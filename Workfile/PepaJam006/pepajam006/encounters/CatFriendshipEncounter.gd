extends BaseEncounter

# Story data for this encounter
var encounter_title = "Feline Philosophy"
var encounter_text = "The cat purrs as you pet it, and you feel a sense of peace wash over you. It's amazing how animals can provide comfort without judgment. After a while, the cat gets up and walks away, leaving you with a smile."

var encounter_choices = [
	{
		"text": "Follow the cat's path",
		"next_scene": "res://encounters/MysteriousAlleyEncounter.tscn"
	},
	{
		"text": "Head home feeling content",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn"
	}
]

func _ready():
	encounter_id = "cat_friendship"
	
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
	# Peaceful cat interaction
	pulse_character(1.1, 1.5)  # Gentle, warm pulse
	await get_tree().create_timer(1.0).timeout
	fade_background(1.0, 2.0)  # Brighten for contentment
