extends Node2D
class_name LevelDialogue

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal intro_finished
signal write_on_finished
signal dialogue_finished
signal level_complete

export(String) var dialogue_resource_path
var dialogue
var current_dialogue_index = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue = load_json_file(dialogue_resource_path)
	$MarginContainer/RichTextLabel.set_percent_visible(0.0)
	load_dialogue(current_dialogue_index)
	$MarginContainer.hide()
	$LabelContinue.hide()
	$LabelGoDeeper.hide()
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func write_on(duration):
	var tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)

	tween.interpolate_property($MarginContainer/RichTextLabel, "percent_visible", 0.0, 1.0, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("write_on_finished")
	tween.queue_free()

func load_dialogue(index):
	if(index > dialogue.result.doctor.size() - 1):
		return
	$MarginContainer/RichTextLabel.clear()
	$MarginContainer/RichTextLabel.append_bbcode(dialogue.result.doctor[index])

func _on_BackgroundGrowing_growing_finished():
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("intro_finished")
	$MarginContainer.show()
	$LabelContinue.show()
	write_on(2)


func _on_MarginContainer_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		print("Window clicked")
		if has_node("Tween"):
			get_node("Tween").stop_all()
			get_node("Tween").emit_signal("tween_completed")
			$MarginContainer/RichTextLabel.percent_visible = 1.0
			return
		current_dialogue_index += 1
		if current_dialogue_index > dialogue.result.doctor.size() - 1:
			emit_signal("dialogue_finished")
			emit_signal("level_complete")
			$LabelContinue.hide()
			$LabelGoDeeper.show()
			return
		load_dialogue(current_dialogue_index)
		write_on(2)

	pass # Replace with function body.


func get_class():
	return "LevelDialogue"
