extends BaseEncounter

# Story data for this encounter
var encounter_title = "Sasa01"
var dialogue = [
		"Hele u Saši se svítí"
	]

var encounter_choices = [
	{
		"text": "Zaklepat",
		"next_scene": "res://encounters/Akt2/Dita/sasa_encounter_01.tscn",
		"effects": {
			"unlock_paths": ["brave_path"],
			"set_flags": {"investigated_bush": true}
		}
	},
	{
		"text": "Jít na tramvaj",
		"next_scene": "res://encounters/Akt2/Skin/skin_encounter_01.tscn",
		"effects": {
			"set_flags": {"ignored_bush": true}
		}
	}
]

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

func setup_encounter_content():
	"""Setup the story content for this encounter"""
	scene_title.text = encounter_title
	left_button.text = encounter_choices[0].text
	right_button.text = encounter_choices[1].text
	
	# Use multi-line dialogue instead of single text
	
	
	# Call after a brief delay to ensure parent is ready
	call_deferred("set_encounter_text", dialogue)

func on_choice_selected(choice_index: int):
	"""Handle choice selection with effects and next scene loading"""
	if choice_index < 0 or choice_index >= encounter_choices.size():
		print("Invalid choice index: ", choice_index)
		return
	
	var choice = encounter_choices[choice_index]
	$VideoStreamPlayer.hide()
	if choice_index == 0:
		$VideoStreamPlayerZ.play()
		$VideoStreamPlayerZ.show()
		await get_tree().create_timer(1.5).timeout
	else:
		$VideoStreamPlayerT.play()
		$VideoStreamPlayerT.show()
		await get_tree().create_timer(2).timeout
	
	
	
	# Process effects if they exist
	if choice.has("effects"):
		var story_manager = get_node("/root/Main/StoryManager")
		if story_manager:
			story_manager.process_effects(choice.effects)
	
	# Load next scene with fade transition
	if choice.has("next_scene"):
		load_scene(choice.next_scene)

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
	var animation_library = AnimationLibrary.new()
	
	# Stumble out animation
	var stumble_anim = Animation.new()
	stumble_anim.length = 2.0
	
	# Character movement track
	var char_track = stumble_anim.add_track(Animation.TYPE_POSITION_3D)
	stumble_anim.track_set_path(char_track, NodePath("Character"))
	stumble_anim.track_insert_key(char_track, 0.0, Vector2(-50, 0))
	stumble_anim.track_insert_key(char_track, 1.0, Vector2(10, -5))
	stumble_anim.track_insert_key(char_track, 2.0, Vector2(0, 0))
	
	animation_library.add_animation("stumble_out", stumble_anim)
	animation_player.add_animation_library("pub_exit", animation_library)



func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.hide()
	$VideoStreamPlayer2.play()
