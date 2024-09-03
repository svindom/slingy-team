extends Control


const MAINSCENE: PackedScene = preload("res://scenes/main/main.tscn")

@onready var level_text: Label = $MarginContainer/VBoxContainer/LevelText
@onready var attempts_text: Label = $MarginContainer/VBoxContainer/AttemptsText
@onready var game_music: AudioStreamPlayer2D = $GameMusic
@onready var level_complete_container: Control = $MarginContainer/LevelCompleteContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_complete_container.hide()
	set_level()
	update_attempts(0)
	SignalManager.on_score_updated.connect(update_attempts)
	SignalManager.on_level_complete.connect(on_level_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu") == true:
		get_tree().change_scene_to_packed(MAINSCENE)


func set_level() -> void:
	level_text.text = "Level: %s" % ScoreManager.get_level_selected()


func update_attempts(attempts: int) -> void:
	attempts_text.text = "Attempts: %s" % attempts


func on_level_complete() -> void:
	level_complete_container.show()
	game_music.play()
