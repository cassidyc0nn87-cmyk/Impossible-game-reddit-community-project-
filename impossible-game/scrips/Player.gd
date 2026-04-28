extends CharacterBody2D

@export var move_speed: float = 200.0
@export var dash_speed: float = 600.0
@export var dash_time: float = 0.15
@export var dash_cooldown: float = 1.0

var dash_timer := 0.0
var dash_cd_timer := 0.0
var dash_direction := Vector2.ZERO

var still_timer := 0.0
var still_limit := 5.0
var last_position := Vector2.ZERO

var survival_time := 0.0
var is_alive := true

@onready var timer_label = get_tree().current_scene.get_node("UI/TimerLabel")
@onready var game_over_ui = get_tree().current_scene.get_node("UI/GameOverUI")
@onready var go_time_label = game_over_ui.get_node("TimeLabel")


func _physics_process(delta):
	if not is_alive:
		return

	# Update survival timer
	survival_time += delta
	timer_label.text = "Time: %.2f" % survival_time

	# Movement input
	var input_vector = Vector2(
		Input.get_action_strength("D_Right") - Input.get_action_strength("D_Left"),
		Input.get_action_strength("D_Down") - Input.get_action_strength("D_Up")
	)

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	# Dash
	if Input.is_action_just_pressed("D_Dash") and dash_cd_timer <= 0.0 and input_vector != Vector2.ZERO:
		dash_timer = dash_time
		dash_cd_timer = dash_cooldown
		dash_direction = input_vector

	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		move_and_slide()
		_check_stillness(delta)
		return

	if dash_cd_timer > 0.0:
		dash_cd_timer -= delta

	velocity = input_vector * move_speed
	move_and_slide()

	_check_stillness(delta)


func _check_stillness(delta):
	var moved = global_position.distance_to(last_position) > 1.0

	if moved:
		still_timer = 0.0
	else:
		still_timer += delta

	if still_timer >= still_limit:
		_game_over()

	last_position = global_position


func _game_over():
	is_alive = false

	# Show Game Over UI
	game_over_ui.visible = true
	go_time_label.text = "You survived: %.2f seconds" % survival_time

	# Freeze enemies
	for node in get_tree().current_scene.get_children():
		if node.has_method("freeze"):
			node.freeze()


func reset_player():
	global_position = Vector2(100, 100)
	velocity = Vector2.ZERO
	survival_time = 0.0
	still_timer = 0.0
	is_alive = true
