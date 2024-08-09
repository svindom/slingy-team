extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
@onready var player_position_marker: Marker2D = $PlayerPosition



# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_new_player()
	SignalManager.on_player_destroyed.connect(on_player_destroyed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_new_player() -> void:
	# Create instances of the scene
	var new_player_scene_instance = PLAYER_SCENE.instantiate()
	# Set the player position
	new_player_scene_instance.position = player_position_marker.position
	# Add a child of the Scene
	#add_child(new_player_scene_instance)
	
	# Defer the addition of the child to the scene
	call_deferred("add_child", new_player_scene_instance)


func on_player_destroyed() -> void:
	spawn_new_player()
	
	
	
