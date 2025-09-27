extends Control
class_name BaseEncounter

signal choice_made(choice_index: int)
signal encounter_ready
signal animation_finished

@export var encounter_id: String = ""
@export var background_texture: Texture2D
@export var character_texture: Texture2D
@export var ambient_sound: AudioStream
@export var choice_sound: AudioStream

@onready var background: TextureRect = $Background
@onready var character: TextureRect = $Character
@onready var scene_title: Label = $UI/VBoxContainer/SceneTitle
@onready var scene_text: RichTextLabel = $UI/VBoxContainer/SceneText
@onready var left_button: Button = $UI/VBoxContainer/ChoiceContainer/LeftChoice
@onready var right_button: Button = $UI/VBoxContainer/ChoiceContainer/RightChoice
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var choice_audio: AudioStreamPlayer = $ChoiceAudioPlayer
@onready var fade_overlay: ColorRect = $FadeOverlay

var encounter_data: Dictionary = {}
var is_animating: bool = false
var typewriter_speed: float = 0.05  # Time between each character/word
var typewriter_mode: String = "letter"  # "letter" or "word"
var is_typing: bool = false

# Fade transition settings
var use_fade_transitions: bool = true
var fade_duration: float = 1.0

func _ready():
	setup_encounter()
	connect_signals()
	

func setup_encounter():
	# Set up visual elements
	if background_texture:
		background.texture = background_texture
	if character_texture:
		character.texture = character_texture
	
	# Set up audio
	if ambient_sound:
		audio_player.stream = ambient_sound
		audio_player.play()
	
	if choice_sound:
		choice_audio.stream = choice_sound
	
	# Configure UI for portrait mode
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func connect_signals():
	left_button.pressed.connect(_on_left_choice_pressed)
	right_button.pressed.connect(_on_right_choice_pressed)
	animation_player.animation_finished.connect(_on_animation_finished)

# Override this method in specific encounter scenes
func setup_encounter_content():
	"""Setup the story content for this encounter - override in child classes"""
	pass

func load_encounter_data(data: Dictionary):
	encounter_data = data
	encounter_id = data.get("id", "")
	
	# Update UI elements
	setup_encounter_content()
	
	# Set up choices
	setup_choices(data.get("choices", []))
	
	# Play entrance animation
	play_entrance_animation()

func setup_choices(choices: Array):
	# Hide buttons initially
	left_button.visible = false
	right_button.visible = false
	
	if choices.size() >= 1:
		left_button.text = choices[0].get("text", "Choice 1")
		left_button.disabled = choices[0].get("disabled", false)
		left_button.visible = true
		
		# Style disabled choices
		if left_button.disabled:
			left_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
		else:
			left_button.modulate = Color.WHITE
	
	if choices.size() >= 2:
		right_button.text = choices[1].get("text", "Choice 2")
		right_button.disabled = choices[1].get("disabled", false)
		right_button.visible = true
		
		# Style disabled choices
		if right_button.disabled:
			right_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
		else:
			right_button.modulate = Color.WHITE

func play_entrance_animation():
	is_animating = true
	
	# Animate text appearance
	scene_text.visible_characters = 0
	var text_tween = create_tween()
	text_tween.tween_method(_animate_text, 0, scene_text.get_total_character_count(), 2.0)
	
	# Play entrance animation if available
	if animation_player.has_animation("entrance"):
		animation_player.play("entrance")
	else:
		# Default entrance animation
		character.modulate.a = 0.0
		var char_tween = create_tween()
		char_tween.tween_property(character, "modulate:a", 1.0, 1.0)
		char_tween.tween_callback(_on_entrance_finished)

func play_exit_animation():
	is_animating = true
	
	# Hide choices during exit
	left_button.visible = false
	right_button.visible = false
	
	if animation_player.has_animation("exit"):
		animation_player.play("exit")
	else:
		# Default exit animation
		var exit_tween = create_tween()
		exit_tween.tween_property(character, "modulate:a", 0.0, 0.5)
		exit_tween.tween_callback(_on_animation_finished)

func play_choice_animation(choice_index: int):
	is_animating = true
	
	# Play choice-specific animation if available
	var anim_name = "choice_" + str(choice_index)
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		# Default choice animation - button feedback
		var button = left_button if choice_index == 0 else right_button
		var original_scale = button.scale
		var choice_tween = create_tween()
		choice_tween.tween_property(button, "scale", original_scale * 1.1, 0.1)
		choice_tween.tween_property(button, "scale", original_scale, 0.1)
		choice_tween.tween_callback(func(): _emit_choice(choice_index))

func play_custom_animation(animation_name: String):
	if animation_player.has_animation(animation_name):
		is_animating = true
		animation_player.play(animation_name)

func _animate_text(visible_chars: int):
	scene_text.visible_characters = visible_chars

func _on_entrance_finished():
	is_animating = false
	# Show choices after entrance animation
	if encounter_data.has("choices"):
		var choices = encounter_data.choices
		if choices.size() >= 1:
			left_button.visible = true
		if choices.size() >= 2:
			right_button.visible = true
	
	encounter_ready.emit()

func _on_animation_finished(anim_name: String):
	is_animating = false
	
	if anim_name == "entrance":
		_on_entrance_finished()
	elif anim_name == "exit":
		animation_finished.emit()
	else:
		animation_finished.emit()

func _on_left_choice_pressed():
	if not is_animating:
		if choice_audio and choice_sound:
			choice_audio.play()
		play_choice_animation(0)

func _on_right_choice_pressed():
	if not is_animating:
		if choice_audio and choice_sound:
			choice_audio.play()
		play_choice_animation(1)

func _emit_choice(choice_index: int):
	choice_made.emit(choice_index)
	# Call the encounter-specific choice handler if it exists
	if has_method("on_choice_selected"):
		call("on_choice_selected", choice_index)

# Override these methods in specific encounter scenes
func on_encounter_start():
	# Called when encounter becomes active
	pass

func on_encounter_end():
	# Called before encounter is unloaded
	if audio_player.playing:
		audio_player.stop()

# Utility methods for custom encounter behavior
func shake_character(intensity: float = 10.0, duration: float = 0.5):
	var original_pos = character.position
	var shake_tween = create_tween()
	shake_tween.set_loops(int(duration * 20))
	shake_tween.tween_method(
		func(_offset): character.position = original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)),
		0.0, 1.0, 0.05
	)
	shake_tween.tween_callback(func(): character.position = original_pos)

func pulse_character(scale_multiplier: float = 1.2, duration: float = 1.0):
	var original_scale = character.scale
	var pulse_tween = create_tween()
	pulse_tween.tween_property(character, "scale", original_scale * scale_multiplier, duration * 0.5)
	pulse_tween.tween_property(character, "scale", original_scale, duration * 0.5)

func fade_background(target_alpha: float, duration: float = 1.0):
	var fade_tween = create_tween()
	fade_tween.tween_property(background, "modulate:a", target_alpha, duration)

# Typewriter effect methods
func start_typewriter_effect(text: String = ""):
	"""Start typewriter effect for the scene text"""
	if text.is_empty():
		text = scene_text.text
	
	is_typing = true
	scene_text.visible_characters = 0
	
	if typewriter_mode == "letter":
		start_letter_by_letter_effect(text)
	else:
		start_word_by_word_effect(text)

func start_letter_by_letter_effect(text: String):
	"""Display text letter by letter"""
	scene_text.text = text
	var total_chars = scene_text.get_total_character_count()
	
	for i in range(total_chars + 1):
		if not is_typing:
			break
		scene_text.visible_characters = i
		await get_tree().create_timer(typewriter_speed).timeout
	
	is_typing = false
	_on_typewriter_finished()

func start_word_by_word_effect(text: String):
	"""Display text word by word"""
	var words = text.split(" ")
	var current_text = ""
	
	scene_text.text = ""
	
	for word in words:
		if not is_typing:
			break
		current_text += word + " "
		scene_text.text = current_text
		await get_tree().create_timer(typewriter_speed * 3).timeout  # Slower for words
	
	is_typing = false
	_on_typewriter_finished()

func skip_typewriter():
	"""Skip the typewriter effect and show full text immediately"""
	is_typing = false
	scene_text.visible_characters = -1  # Show all characters
	_on_typewriter_finished()  # Show buttons immediately

func _on_typewriter_finished():
	"""Called when typewriter effect is complete"""
	# Show choice buttons after text is fully displayed
	# Check if this encounter has choices (either old or new system)
	var has_choices = false
	var choice_count = 0
	
	# New system: check if encounter has encounter_choices variable
	if has_method("get") and get("encounter_choices") != null:
		var choices = get("encounter_choices")
		if choices is Array:
			choice_count = choices.size()
			has_choices = choice_count > 0
	# Old system: check encounter_data
	elif encounter_data.has("choices"):
		var choices = encounter_data.choices
		choice_count = choices.size()
		has_choices = choice_count > 0
	
	if has_choices:
		if choice_count >= 1:
			left_button.visible = true
		if choice_count >= 2:
			right_button.visible = true

func set_typewriter_speed(speed: float):
	"""Set the speed of the typewriter effect"""
	typewriter_speed = speed

func set_typewriter_mode(mode: String):
	"""Set typewriter mode: 'letter' or 'word'"""
	if mode in ["letter", "word"]:
		typewriter_mode = mode

func _input(event):
	"""Handle input for skipping typewriter effect"""
	if is_typing and (event is InputEventScreenTouch or event is InputEventMouseButton):
		if event.pressed:
			skip_typewriter()

# Fade transition methods

func fade_in():
	"""Fade in from black overlay"""
	if not use_fade_transitions or not fade_overlay:
		return
	
	fade_overlay.color = Color(0, 0, 0, 1)  # Start fully black
	fade_overlay.visible = true
	fade_overlay.z_index = 100  # Ensure it's on top
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween.finished
	fade_overlay.visible = false

func fade_out(duration: float = -1.0):
	"""Fade out to black"""
	if not use_fade_transitions or not fade_overlay:
		return
	
	var fade_time = duration if duration > 0 else fade_duration
	fade_overlay.color = Color(0, 0, 0, 0)  # Start transparent
	fade_overlay.visible = true
	fade_overlay.z_index = 100  # Ensure it's on top
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_time)
	await tween.finished

func fade_out_and_load_scene(scene_path: String, duration: float = -1.0):
	"""Fade out and then load a new scene"""
	if use_fade_transitions:
		var fade_time = duration if duration > 0 else fade_duration
		fade_out(fade_time)
		await get_tree().create_timer(fade_time).timeout
	
	# Load the new scene
	var story_manager = get_node("/root/Main/StoryManager")
	if story_manager:
		story_manager.load_encounter(scene_path)

func set_fade_transitions(enabled: bool):
	"""Toggle fade transitions on/off"""
	use_fade_transitions = enabled

func set_fade_duration(duration: float):
	"""Set the duration of fade transitions"""
	fade_duration = duration
