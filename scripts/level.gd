extends Node2D

const CELL_SIZE = {
	x = 16,
	y = 16
}

signal goal_entered

# Declare member variables here. Examples:
var is_player_moving = false
var goal_entered = false
var debug_line_arrow


# Called when the node enters the scene tree for the first time.
func _ready():
	#debug_line_arrow = debug_line($Player.global_position, $Player.arrow.direction * 10, Color(0, 0, 1, 1))
	$Player.hide()
	$Map.hide()
	$Goal.hide()
	$BackgroundGrowing.start()

func start_level():
	reset()
	$Player.position = $PlayerStartPosition.position
	$Player.show()
	$Player.show_arrow()
	$Map.show()
	$Goal.show()

func reset():
	if $Player.has_node("Tween"):
		$Player.get_node("Tween").stop_all()
		$Player.get_node("Tween").emit_signal("tween_completed")
	$Goal/CollisionShape2D.set_deferred("disabled", false)
	goal_entered = false

func debug_line(from, to, color):
	var line = Line2D.new()
	add_child(line)
	line.set_default_color(color)
	line.set_width(1.0)
	line.add_point(from)
	line.add_point(to)
	return line

func raycast_and_move(space_state):
# Use global coordinates
	# Debug Line for Arrow Direction
	#debug_line($Player.global_position, $Player.global_position + $Player.arrow.direction * 240, Color( 1, 0, 0, 1))

	var result = space_state.intersect_ray($Player.global_position, $Player.global_position + $Player.arrow.direction * 240, [$Player])
	
	if result:
		# Debug lien for the raytracea and collision
		#debug_line($Player.global_position, result.position, Color(0, 1, 0, 1))

		if $Player.global_position.distance_to(result.position) <= 8:
			return

		# Snap to the grid
		var snapped_position = (result.position - ($Player.arrow.direction * 8)).snapped(Vector2(CELL_SIZE.x / 2, CELL_SIZE.y / 2))

		is_player_moving = true
		$Player.move(snapped_position, 2)


func _physics_process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and !is_player_moving and !goal_entered:
		var space_state = get_world_2d().direct_space_state
		raycast_and_move(space_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Player.update_arrow_direction(get_global_mouse_position())
	#debug_line_arrow.set_point_position(0, $Player.global_position)
	#debug_line_arrow.set_point_position(1, $Player.global_position + $Player.arrow.direction * 10.0)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		start_level()



func _on_Player_movement_finished():
	is_player_moving = false


func _on_Goal_area_entered(area):
	if area == $Player:
		print("Player reached the goal!")
		$Goal/CollisionShape2D.set_deferred("disabled", true)
		emit_signal("goal_entered")
		goal_entered = true


func _on_BackgroundGrowing_growing_finished():
	start_level()
