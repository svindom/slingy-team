extends Area2D


@onready var water_splash_sound: AudioStreamPlayer2D = $WaterSplashSound



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	SignalManager.on_player_destroyed.emit()
	water_splash_sound.play()
