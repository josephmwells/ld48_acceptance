extends Node2D
class_name LevelPuzzle

const CELL_SIZE = {
	x = 16,
	y = 16
}

signal level_complete
signal goal_entered
signal intro_finished
signal thought_ready(thought)

# Declare member variables here. Examples:
export(String) var dialogue_resource_path
var dialogue

var is_player_moving = false
var goal_entered = false
var window_active = false
var debug_line_arrow


# Called when the node enters the scene tree for the first time.
func _ready():
	#debug_line_arrow = debug_line($Player.global_position, $Player.arrow.direction * 10, Color(0, 0, 1, 1))
	dialogue = load_json_file(dialogue_resource_path)
	$Player.hide()
	$Map.hide()
	$Goal.hide()
	$BackgroundGrowing.start()


func load_json_file(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = file.get_as_text()
	file.close()
	var json = JSON.parse(text)
	return json


func start_level():
	reset()
	$Player.position = $PlayerStartPosition.position
	$Player.show()
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
	#debug_line($Player.position, $Player.position + $Player.arrow.direction * 240, Color( 1, 0, 0, 1))

	var result = space_state.intersect_ray($Player.global_position, $Player.global_position + $Player.arrow.direction * 240, [$Player])
	
	if result:
		# Debug lien for the raytracea and collision
		#debug_line($Player.position, result.position - global_position, Color(0, 1, 0, 1))

		if $Player.global_position.distance_to(result.position) <= 8:
			return

		# Snap to the grid
		var snapped_position = (result.position - ($Player.arrow.direction * 8)).snapped(Vector2(CELL_SIZE.x / 2, CELL_SIZE.y / 2))

		is_player_moving = true
		$Player.move(snapped_position, 2)
		$Player.hide_arrow()


func _physics_process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and window_active and !is_player_moving and !goal_entered:
		var space_state = get_world_2d().direct_space_state
		raycast_and_move(space_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Player.update_arrow_direction(get_global_mouse_position())
	#debug_line_arrow.set_point_position(0, $Player.position)
	#debug_line_arrow.set_point_position(1, $Player.position + $Player.arrow.direction * 10.0)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		start_level()



func _on_Player_movement_finished():
	is_player_moving = false
	if !goal_entered:
		$Player.show_arrow()


func _on_Goal_area_entered(area):
	if area == $Player:
		print("Player reached the goal!")
		$Goal/CollisionShape2D.set_deferred("disabled", true)
		$Player.hide_arrow()
		emit_signal("goal_entered")
		emit_signal("level_complete")
		goal_entered = true


func _on_BackgroundGrowing_growing_finished():
	emit_signal("intro_finished")
	emit_signal("thought_ready", dialogue.result.internal[0])
	start_level()


func _on_ClickArea_input_event(viewport, event, shape_idx):
	pass # Replace with function body.


func _on_ClickArea_mouse_entered():
	window_active = true
	if !is_player_moving and !goal_entered:
		$Player.show_arrow()


func _on_ClickArea_mouse_exited():
	window_active = false
	$Player.hide_arrow()

func get_class():
	return "LevelPuzzle"
