extends Node


var _attemts: int = 0
var _cup_hits: int = 0
var _total_cups: int = 0
var _level_number: int = 1


func _ready():
	_total_cups = get_tree().get_nodes_in_group("cup").size()
	_level_number = ScoreManager.get_level_selected()
	SignalManager.on_attemt_made.connect(increase_attemps_number)
	SignalManager.on_cup_destroyed.connect(increase_cup_hits_number)

func increase_attemps_number() -> void:
	_attemts += 1
	SignalManager.on_score_updated.emit(_attemts)
	
func increase_cup_hits_number() -> void:
	_cup_hits += 1
	if _cup_hits == _total_cups:
		SignalManager.on_level_complete.emit()
		ScoreManager.set_score_for_level(_attemts, str(_level_number))
