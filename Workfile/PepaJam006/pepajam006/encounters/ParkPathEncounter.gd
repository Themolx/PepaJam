extends BaseEncounter

# Story data for this encounter
var encounter_title = "The Sensible Route"
var encounter_text = "You wisely ignore the mysterious sounds and continue on the path. A couple walks by holding hands, making you feel slightly lonely but also relieved you didn't end up in a horror movie scenario."

var encounter_choices = [
	{
		"text": "Sit on a bench and contemplate life",
		"next_scene": "res://encounters/PhilosophicalMomentEncounter.tscn"
	},
	{
		"text": "Speed up to get home faster",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn"
	}
]

func _ready():
	encounter_id = "park_path"
	
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
	# Peaceful park atmosphere
	fade_background(0.9, 1.0)
	await get_tree().create_timer(0.8).timeout
	pulse_character(1.05, 2.0)  # Gentle pulse for peaceful mood
