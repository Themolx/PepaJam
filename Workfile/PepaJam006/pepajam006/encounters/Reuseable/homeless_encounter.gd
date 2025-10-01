extends BaseEncounter

# Story data for this encounter
var encounter_title = "An Unlikely Guide"
var encounter_text = "Nemáš cígo?"



@export var next_scene_set_1: String = "res://encounters/Akt2/Dita/dita_encounter_03.tscn"
@export var next_scene_set_2: String = "res://encounters/Akt2/Dita/dita_encounter_03.tscn"

var encounter_choices = [
	{
		"text": "Dát cígo.",
		"next_scene": next_scene_set_1,
		"effects": {
			"unlock_paths": ["artistic_path"]
		}
	},
	{
		"text": "Sam nemam.",
		"next_scene": next_scene_set_2
	}
]


func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text
	
	# Use the new dialogue system for better text handling
	set_encounter_text(encounter_text)

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	var next_scene = next_scene_set_1
	if choice_index == 0:
		$VideoStreamPlayerH.play()
		$VideoStreamPlayerH.show()
		await get_tree().create_timer(2).timeout
		next_scene = next_scene_set_1
	else:
		$VideoStreamPlayerS.play()
		$VideoStreamPlayerS.show()
		await get_tree().create_timer(1.5).timeout
		next_scene = next_scene_set_2
	
	# Process effects if they exist
	if choice.has("effects"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.process_effects(choice.effects)
	
	# Load next scene
	if choice.has("next_scene"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.load_encounter(next_scene)

func _ready():
	encounter_id = "pub_exit"
	# Set specific assets for this encounter
	# background_texture = preload("res://assets/backgrounds/pub_exterior.png")
	# character_texture = preload("res://assets/characters/player_drunk.png")
	# ambient_sound = preload("res://assets/audio/night_ambience.ogg")
	# choice_sound = preload("res://assets/audio/footstep.ogg")
	
	# Customize typewriter settings for this encounter
	set_typewriter_mode("letter")  # or "word"
	set_typewriter_speed(0.03)  # Faster typing for drunk stumbling effect
	
	# Set the story content
	setup_encounter_content()
	
	super._ready()




func on_encounter_start():
	# Fade in when encounter starts
	fade_in()
	
	# Play custom entrance animation for pub exit
	play_custom_animation("stumble_out")
	
	# Add some comedy timing
	await get_tree().create_timer(1.0).timeout
	shake_character(5.0, 0.3)

func setup_animations():
	# Create custom animations for this encounter
	pass

func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer2.play()
	$VideoStreamPlayer.hide()
