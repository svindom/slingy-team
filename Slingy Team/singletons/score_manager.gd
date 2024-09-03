extends Node


const DEFAULT_SCORE: int = 1000
const SCORE_PATH = "user://slingy_team.json"


var _level_selected: int = 1
var _level_scores_dictionary: Dictionary = {}




func _ready() -> void:
	load_from_disc()


func set_level_selected(level_selected: int) -> void:
	_level_selected = level_selected


func get_level_selected() -> int:
	return _level_selected


func check_and_add(level: String) -> void:
	# level is a String in this case
	if _level_scores_dictionary.has(level) == false:
		_level_scores_dictionary[level] = DEFAULT_SCORE


func set_score_for_level(score: int, level: String) -> void:
	check_and_add(level)
	if _level_scores_dictionary[level] > score:
		_level_scores_dictionary[level] = score
		save_to_disc()


func get_best_for_level(level: String) -> int:
	check_and_add(level)
	return _level_scores_dictionary[level]


func save_to_disc() -> void:
	# 'file' is of type FileAccess, which is used to manage file reading and writing operations.
	var file: FileAccess = FileAccess.open(SCORE_PATH, FileAccess.WRITE)
	var score_json_str: String = JSON.stringify(_level_scores_dictionary)
	file.store_string(score_json_str)


func load_from_disc() -> void:
	var file: FileAccess = FileAccess.open(SCORE_PATH, FileAccess.READ)
	if file == null:
		save_to_disc()
	else:
		var data: String = file.get_as_text()
		_level_scores_dictionary = JSON.parse_string(data)
	
	
