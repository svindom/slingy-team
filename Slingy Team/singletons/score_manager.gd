extends Node


const DEFAULT_SCORE: int = 1000

var _level_selected: int = 1
var _level_scores_dictionary: Dictionary = {}




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


func get_best_for_level(level: String) -> int:
	check_and_add(level)
	return _level_scores_dictionary[level]
