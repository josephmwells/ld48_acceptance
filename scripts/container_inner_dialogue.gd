extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	clear()


func clear():
	$RichTextLabel.clear()
	$RichTextLabel.set_percent_visible(0.0)

func write_on(text, duration):
	$RichTextLabel.clear()
	$RichTextLabel.append_bbcode(text)
	var tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)

	tween.interpolate_property($RichTextLabel, "percent_visible", 0.0, 1.0, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("write_on_finished")
	tween.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
