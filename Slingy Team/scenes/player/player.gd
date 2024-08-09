extends RigidBody2D


enum PLAYER_STATE {
	READY,
	DRAG,
	RELEASE
}
var _state_enum: PLAYER_STATE = PLAYER_STATE.READY

@onready var water_splash_animation: AnimatedSprite2D = $WaterSplashAnimation
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var player_delete_timer: Timer = $PlayerDeleteTimer

@onready var label: Label = $Label



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_player_destroyed.connect(delete_player)
	water_splash_animation.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	update_enum_state_each_frame(delta)
	update_label()


func set_new_state_enum(new_state_enum: PLAYER_STATE) -> void:
	_state_enum = new_state_enum
	set_player_freeze_off()


func set_player_freeze_off() -> void:
	if _state_enum == PLAYER_STATE.RELEASE:
		freeze = false
	elif _state_enum == PLAYER_STATE.DRAG:
		pass
		# I need to change a name of this function when I add a new logic here!!!


func update_enum_state_each_frame(delta: float) -> void:
	match _state_enum:
		PLAYER_STATE.DRAG:
			update_drag_to_release()


func update_drag_to_release() -> void:
	if is_detect_input_released() == true:
		# 'Return' is used here to check if the player is released
		# If it's true, it exits the function and the rest of the code won't be executed
		return
	
	var global_mouse_position: Vector2 = get_global_mouse_position()
	# 'position' here is a position of the player
	position = global_mouse_position


func is_detect_input_released() -> bool:
	if _state_enum == PLAYER_STATE.DRAG:
		is_player_released_drag_to_fly()
	return false


func is_player_released_drag_to_fly() -> bool:
	if Input.is_action_just_released("drag") == true:
		set_new_state_enum(PLAYER_STATE.RELEASE)
		return true
	return false


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
	if _state_enum == PLAYER_STATE.READY and event.is_action_pressed("drag"):
		set_new_state_enum(PLAYER_STATE.DRAG)


func update_label() -> void:
	label.text = "%s" % PLAYER_STATE.keys()[_state_enum]
