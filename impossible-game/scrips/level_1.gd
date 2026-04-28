extends Node2D

@onready var RetryButton = $UI/GameOverUI/RetryButton

# --- START MENU NODES ---
@onready var start_menu = $UI/StartMenu
@onready var title = $UI/StartMenu/TitleLabel
@onready var press_enter = $UI/StartMenu/PressEnterLabel
@onready var start_sound = $UI/StartMenu/StartSound

var bob_time := 0.0
var blink_time := 0.0
var game_started := false
# -------------------------

var player_spawn := Vector2.ZERO
var enemy_spawns := {}

func _ready():
	$UI/GameOverUI.visible = false

	# Save original spawn positions
	player_spawn = $Player.global_position

	for node in get_children():
		if node.has_method("freeze"):
			enemy_spawns[node] = node.global_position

	# FULL FREEZE: stop ALL gameplay until start
	$Player.set_process(false)
	$Player.set_physics_process(false)

	for node in get_children():
		if node.has_method("freeze"):
			node.set_process(false)
			node.set_physics_process(false)


func _process(delta):
	# --- START MENU LOGIC ---
	if not game_started:
		bob_time += delta
		title.position.y = 150 + sin(bob_time * 2.0) * 10.0

		blink_time += delta
		press_enter.visible = int(blink_time * 2.0) % 2 == 0

		# YOU USE A_Enter, NOT ui_accept
		if Input.is_action_just_pressed("A_Enter"):
			_start_game()
		return
	# -------------------------


func _start_game():
	game_started = true

	if start_sound.stream:
		start_sound.play()

	await get_tree().create_timer(0.15).timeout

	start_menu.visible = false

	# UNFREEZE EVERYTHING
	$Player.set_process(true)
	$Player.set_physics_process(true)

	for node in get_children():
		if node.has_method("freeze"):
			node.set_process(true)
			node.set_physics_process(true)


func _on_retry_button_pressed():
	print("REPLAY BUTTON PRESSED") # debug

	# Hide Game Over UI
	$UI/GameOverUI.visible = false

	# Reset player to original spawn
	$Player.reset_player()
	$Player.global_position = player_spawn

	# Reset enemies to original spawns
	for node in get_children():
		if node.has_method("freeze"):
			node.frozen = false
			node.global_position = enemy_spawns[node]
