extends CharacterBody2D

var player

var move_speed := 100.0

# BOOST SYSTEM
var boost_speed := 300.0
var boost_timer := 0.0
var boost_duration := 5.0
var boost_cooldown := 0.0
var boost_cooldown_max := 30.0
var boost_chance := 0.01

# TELEPORT SYSTEM
var teleport_cooldown := 0.0
var teleport_cooldown_max := 30.0
var teleport_chance := 0.002

# PATHFINDING
var nav: NavigationAgent2D

# NEW — freeze flag
var frozen := false


func _ready():
	player = get_parent().get_node("Player")
	nav = $NavigationAgent2D

	nav.max_speed = move_speed
	nav.path_desired_distance = 2.0
	nav.target_desired_distance = 2.0


func _physics_process(delta):
	# NEW — stop enemy if frozen
	if frozen:
		return

	# STOP IF PLAYER IS DEAD
	if player == null or not player.is_alive:
		return

	nav.target_position = player.global_position

	# BOOST ACTIVE
	if boost_timer > 0.0:
		boost_timer -= delta
		var dir_boost = (player.global_position - global_position).normalized()
		velocity = dir_boost * boost_speed
		move_and_slide()
		_check_player_collision()
		return

	# BOOST COOLDOWN
	if boost_cooldown > 0.0:
		boost_cooldown -= delta
	else:
		if randf() < boost_chance:
			boost_timer = boost_duration
			boost_cooldown = boost_cooldown_max

	# TELEPORT
	if teleport_cooldown > 0.0:
		teleport_cooldown -= delta
	else:
		if randf() < teleport_chance:
			var new_x = randf_range(0, get_viewport_rect().size.x)
			var new_y = randf_range(0, get_viewport_rect().size.y)
			global_position = Vector2(new_x, new_y)
			teleport_cooldown = teleport_cooldown_max
			nav.target_position = player.global_position

	# PATHFINDING
	var direction := Vector2.ZERO

	if not nav.is_navigation_finished():
		var next_point = nav.get_next_path_position()
		if next_point.distance_to(global_position) > 1.0:
			direction = (next_point - global_position).normalized()
		else:
			direction = (player.global_position - global_position).normalized()
	else:
		direction = (player.global_position - global_position).normalized()

	velocity = direction * move_speed
	move_and_slide()

	_check_player_collision()


# NEW — freeze function for game over
func freeze():
	frozen = true
	velocity = Vector2.ZERO


# UPDATED — only change is calling player's new _game_over()
func _check_player_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			player._game_over()
