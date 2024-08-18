extends RigidBody2D


@export var _impulse_mult: float = 20.0
@export var _impulse_max: float = 1000.0 

@onready var ball_sprite: Sprite2D = $BallSprite
@onready var arrow: Sprite2D = $Arrow
@onready var player_delete_timer: Timer = $PlayerDeleteTimer
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var cup_sound: AudioStreamPlayer2D = $CupSound

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
var _previous_dragged_vector: Vector2 = Vector2.ZERO # Previous vector that we dragged from. To have data between the previos and last drags.

var _arrow_scale_x_axis: float = 0.0

var _last_collision_count: int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	_arrow_scale_x_axis = arrow.scale.x
	
	arrow.hide()
	_start_player_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.S
func _physics_process(delta: float):
	update_enum_state_each_frame(delta)
	update_label()


func get_impulse_to_player() -> Vector2:
	var reverse_direction_value: int = -1
	var impulse: Vector2 = _dragged_vector * reverse_direction_value * _impulse_mult
	return impulse


func set_new_state_enum(new_state_enum: PLAYER_STATE) -> void:
	_state_enum = new_state_enum
	
	if _state_enum == PLAYER_STATE.RELEASE:
		arrow.hide()
		label.hide()
		freeze = false
		apply_central_impulse(get_impulse_to_player())
		launch_sound.play()
		SignalManager.on_attemt_made.emit()
	elif _state_enum == PLAYER_STATE.DRAG:
		_drag_start_position = get_global_mouse_position()
		arrow.show()


func update_enum_state_each_frame(delta: float) -> void:
	match _state_enum:
		PLAYER_STATE.DRAG:
			update_drag_to_release()
		PLAYER_STATE.RELEASE:
			update_in_flight()


func update_drag_to_release() -> void:
	if is_detect_input_released() == true:
		# 'Return' is used here to check if the player is released
		# If it's true, it exits the function and the rest of the code won't be executed
		return
	
	var global_mouse_position: Vector2 = get_global_mouse_position()
	
	_dragged_vector = get_dragged_vector(global_mouse_position)
	play_stretch_sound()
	dragg_in_limits()
	rotate_scale_arrow()


func get_dragged_vector(global_mouse_position: Vector2) -> Vector2:
	var dragged_vector: Vector2 = global_mouse_position - _drag_start_position
	return dragged_vector


func dragg_in_limits() -> void:
	# here we update each time the _previous_dragged_vector to the updated version, which is _dragged_vector
	_previous_dragged_vector = _dragged_vector
	
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


func rotate_scale_arrow() -> void:
	var impulse_length = get_impulse_to_player().length()
	var percentage = impulse_length / _impulse_max
	
	arrow.scale.x = (_arrow_scale_x_axis * percentage) + _arrow_scale_x_axis
	
	var vector_direction_between_start_and_last_positions: Vector2 = _start_player_position - position
	arrow.rotation = vector_direction_between_start_and_last_positions.angle()


func play_stretch_sound() -> void:
	var difference_between_last_and_previous_vectors = _dragged_vector - _previous_dragged_vector
	if difference_between_last_and_previous_vectors.length() > 0:
		if stretch_sound.playing == false: # to avoid overlapping sounds
			stretch_sound.play()


func play_cup_collision_sound() -> void:
	if _last_collision_count == 0 and get_contact_count() > 0 and cup_sound.playing == false:
		cup_sound.play()
	_last_collision_count = get_contact_count()


func update_in_flight() -> void:
	play_cup_collision_sound()


func on_water_collision() -> void:
	ball_sprite.hide()
	label.hide()


func _on_input_event(_viewport, event, _shape_idx):
	if _state_enum == PLAYER_STATE.READY and event.is_action_pressed("drag"):
		set_new_state_enum(PLAYER_STATE.DRAG)


func _on_visible_on_screen_notifier_2d_screen_exited():
	delete_player()


func delete_player() -> void:
	#SignalManager.on_player_destroyed.emit()
	ball_sprite.hide()
	player_delete_timer.start()


func _on_player_delete_timer_timeout() -> void:
	SignalManager.on_player_destroyed.emit()
	queue_free()


func update_label() -> void:
	# keys method returns an array of all the names in the enum
	label.text = "%s\n" % PLAYER_STATE.keys()[_state_enum]
	
	label.text += "%.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]


func _on_sleeping_state_changed() -> void:
	if sleeping == true:
		var colliding_bodies: Array = get_colliding_bodies()
		if colliding_bodies.size() > 0:
			colliding_bodies[0].destroy_cup()
		delete_player()
