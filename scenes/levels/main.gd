extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_level_index = 0
var current_level

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_next_scene():
	current_level_index += 1
	
	var next_level_resource = load("res://scenes/levels/level_0" + str(current_level_index) + ".tscn")
	var next_level = next_level_resource.instance()

	next_level.connect("goal_entered", self, "_on_Level_goal_entered")
	next_level.position = $LevelSpawnPosition.position
	add_child(next_level)
	
	yield(next_level, "intro_finished")
	
	if current_level:
		var level = current_level
		remove_child(current_level)
		level.call_deferred("free")
	
	current_level = next_level


func _on_Level_goal_entered():
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", false)

func _on_TextureButton_pressed():
	load_next_scene()
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", true)


func _on_ButtonRefocus_pressed():
	current_level.start_level()
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", true)
