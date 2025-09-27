extends BaseEncounter

# Story data for this encounter
var encounter_title = "Bench Wisdom"
var encounter_text = "You sit on the bench and watch the world go by. A cat approaches and sits next to you, as if it understands your need for companionship. Sometimes the best conversations are the ones without words."

var encounter_choices = [
	{
		"text": "Pet the cat and stay longer",
		"next_scene": "res://encounters/CatFriendshipEncounter.tscn"
	},
	{
		"text": "Get up and continue home",
		"next_scene": "res://encounters/HomeArrivalEncounter.tscn"
	}
]

func _ready():
	encounter_id = "philosophical_moment"
	
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
	# Contemplative atmosphere
	fade_background(0.7, 2.0)  # Darker for evening contemplation
	await get_tree().create_timer(1.5).timeout
	pulse_character(0.95, 3.0)  # Slow, thoughtful pulse
