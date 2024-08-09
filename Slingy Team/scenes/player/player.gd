extends RigidBody2D


@onready var water_splash_animation: AnimatedSprite2D = $WaterSplashAnimation
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var player_delete_timer: Timer = $PlayerDeleteTimer



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_player_destroyed.connect(delete_player)
	water_splash_animation.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func play_water_spalash_animation() -> void:
	water_splash_animation.show()
	water_splash_animation.play("water_splash_animation")


func delete_player() -> void:
	ball_sprite.hide()
	play_water_spalash_animation()
	player_delete_timer.start()


func _on_player_delete_timer_timeout() -> void:
	queue_free()


func _on_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
