extends Node2D


const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
@onready var player_position_marker: Marker2D = $PlayerPosition

@onready var water_splash_animation: AnimatedSprite2D = $WaterSplashAnimation
@onready var water: Area2D = $Water

var _ball_position: Vector2 = Vector2.ZERO
var _water_animation_position: Vector2 = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_new_player()
	SignalManager.on_player_destroyed.connect(on_player_destroyed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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



func _on_water_body_entered(body: Node):
	if body.is_in_group(GameManager.PLAYER_GROUP_NAME):
		_water_animation_position = body.position
		water_splash_animation.position = _water_animation_position
		water_splash_animation.show()
		water_splash_animation.play("water_splash_animation")
		body.on_water_collision()
