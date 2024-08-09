extends RigidBody2D


@onready var water_splash_animation: AnimatedSprite2D = $WaterSplashAnimation
@onready var ball_sprite: Sprite2D = $BallSprite




# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_player_destroyed.connect(play_water_spalash_animation)
	water_splash_animation.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func play_water_spalash_animation() -> void:
	ball_sprite.hide()
	water_splash_animation.show()
	water_splash_animation.play("water_splash_animation")
	
	
