extends BaseEncounter

# Story data for this encounter
var encounter_title = "The Busy Street"
var encounter_text = "Cars zoom past you on the main road. You spot a late-night food truck with a long queue of drunk people. Your stomach rumbles."

var encounter_choices = [
	{
		"text": "Join the food truck queue",
		"next_scene": "res://encounters/FoodTruckEncounter.tscn",
		"effects": {
			"unlock_paths": ["food_lover_path"],
			"set_flags": {"bought_food": true}
		}
	},
	{
		"text": "Keep walking home",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn",
		"effects": {
			"set_flags": {"resisted_food": true}
		}
	}
]

func _ready():
	encounter_id = "main_road"
	
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
	# Street atmosphere with car sounds
	fade_background(0.8, 1.0)  # Slightly darker for night street
	await get_tree().create_timer(0.5).timeout
	shake_character(2.0, 0.3)  # Traffic vibrations
