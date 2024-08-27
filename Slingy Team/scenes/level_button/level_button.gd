extends TextureButton


const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)
const DEFAULT_SCALE: Vector2 = Vector2(1.0, 1.0) 

@export var level_number: int = 1

@onready var level_text: Label = $MarginContainer/VBoxContainer/LevelText
@onready var score_text: Label = $MarginContainer/VBoxContainer/ScoreText

var _level_scene: PackedScene

func _ready() -> void:
	level_text.text = str(level_number)
	var best_score = ScoreManager.get_best_for_level(str(level_number))
	score_text.text = str(best_score)
	
	_level_scene = load("res://scenes/level/level%s.tscn" % level_number)


func _on_pressed() -> void:
	ScoreManager.set_level_selected(level_number)
	get_tree().change_scene_to_packed(_level_scene)


func _on_mouse_entered() -> void:
	scale = HOVER_SCALE # Replace with function body.


func _on_mouse_exited() -> void:
	scale = DEFAULT_SCALE # Replace with function body.
