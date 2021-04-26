extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_level_index = 0
var current_level
var game_completed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_next_scene("res://scenes/levels/level_00.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_next_scene(path):
	
	var next_level_resource = load(path)
	var next_level = next_level_resource.instance()
	
	print(get_children())

	next_level.connect("level_complete", self, "_on_Level_level_complete")
	if next_level.get_class() == "LevelPuzzle":
		next_level.connect("thought_ready", self, "_on_Level_thought_ready")
		$MarginContainer/VBoxContainer/ButtonRefocus.set_deferred("disabled", false)
	if next_level.get_class() == "LevelDialogue":
		$MarginContainer/VBoxContainer/ButtonRefocus.set_deferred("disabled", true)
	next_level.position = $LevelSpawnPosition.position
	add_child(next_level)
	
	if current_level and current_level.get_class() == "LevelPuzzle":
		current_level.get_node("Player/Light2D").queue_free()
	
	yield(next_level, "intro_finished")
	
	if current_level:
		var level = current_level
		remove_child(current_level)
		level.call_deferred("free")
	
	current_level = next_level


func _on_Level_thought_ready(thought):
	print("Thought ready")
	print(thought)
	$ContainerInternalDialogue.write_on(thought, 2)

func _on_Level_level_complete():
	if !game_completed:
		$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", false)
		return

func _on_TextureButton_pressed():
	$ContainerInternalDialogue.clear()
	current_level_index += 1
	
	if current_level_index == 13:
		game_completed = true
		
	load_next_scene("res://scenes/levels/level_0" + str(current_level_index) + ".tscn")
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", true)


func _on_ButtonRefocus_pressed():
	current_level.start_level()
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", true)
	
func _on_ButtonWakeUp_pressed():
	if !game_completed:
		current_level_index = 0
		game_completed = false
		load_next_scene("res://scenes/levels/level_wakeup_fail.tscn")
		return
	current_level_index = 0
	game_completed = false
	$MarginContainer/VBoxContainer/ButtonGoDeeper.set_deferred("disabled", false)
	load_next_scene("res://scenes/levels/level_wakeup_success.tscn")
