extends RigidBody2D


@onready var water_splash_animation: AnimatedSprite2D = $WaterSplashAnimation
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var player_delete_timer: Timer = $PlayerDeleteTimer

@onready var label: Label = $Label


const  DRAG_LIMITED_MAX_VALUE_POSITION = Vector2(0, 60)
const DRAG_LIMITED_MIN_VALUE_POSITION = Vector2(-60, 0)

enum PLAYER_STATE {
	READY,
	DRAG,
	RELEASE
}
var _state_enum: PLAYER_STATE = PLAYER_STATE.READY

var _start_player_position: Vector2 = Vector2.ZERO # position of a ball
var _drag_start_position: Vector2 = Vector2.ZERO # finger or a mouse position when it starts dragging
var _dragged_vector: Vector2 = Vector2.ZERO # is the amount we've actually dragged versus the drag start. So we know how much impulse to apply.



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_player_destroyed.connect(delete_player)
	water_splash_animation.hide()
	_start_player_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	update_enum_state_each_frame(delta)
	update_label()


func set_new_state_enum(new_state_enum: PLAYER_STATE) -> void:
	_state_enum = new_state_enum
	
	if _state_enum == PLAYER_STATE.RELEASE:
		freeze = false
	elif _state_enum == PLAYER_STATE.DRAG:
		_drag_start_position = get_global_mouse_position()


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
	
	_dragged_vector = get_dragged_vector(global_mouse_position)
	dragg_in_limits()


func get_dragged_vector(global_mouse_position: Vector2) -> Vector2:
	var dragged_vector: Vector2 = global_mouse_position - _drag_start_position
	return dragged_vector


func dragg_in_limits() -> void:
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIMITED_MIN_VALUE_POSITION.x, DRAG_LIMITED_MAX_VALUE_POSITION.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIMITED_MIN_VALUE_POSITION.y, DRAG_LIMITED_MAX_VALUE_POSITION.y)
	change_player_position(_start_player_position, _dragged_vector)


func change_player_position(start_position: Vector2, moved_position: Vector2) -> Vector2:
	var new_position: Vector2 = start_position + moved_position
	position = new_position # This updates the position of the player
	return new_position


func is_detect_input_released() -> bool:
	if _state_enum == PLAYER_STATE.DRAG:
		is_player_released_button()
	return false


func is_player_released_button() -> bool:
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
	# keys method returns an array of all the names in the enum
	label.text = "%s\n" % PLAYER_STATE.keys()[_state_enum]
	
	label.text += "%.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]
