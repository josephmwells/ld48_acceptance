extends Area2D


# Declare member variables here. Examples:
signal movement_finished
var arrow = {
	direction = Vector2(0, 1)
}


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_arrow()

func move(pos, duration):
	var tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)

	tween.interpolate_property(self, "global_position", global_position, pos, duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("movement_finished")
	tween.queue_free()

func show_arrow():
	$ArrowSprite.show()

func hide_arrow():
	$ArrowSprite.hide()

func update_arrow_direction(pos):
	var angle = global_position.direction_to(pos).angle()
	if(angle > -(3 * PI) / 4):
		$ArrowSprite.position = Vector2(0, -1) * 16
		$ArrowSprite.rotation = 3 * PI / 2
	if(angle > -(PI / 4)):
		$ArrowSprite.position = Vector2(1, 0) * 16
		$ArrowSprite.rotation = 0
	if(angle > PI / 4):
		$ArrowSprite.position = Vector2(0, 1) * 16
		$ArrowSprite.rotation = PI / 2
	if(angle > (3 * PI) / 4):
		$ArrowSprite.position = Vector2(-1, 0) * 16
		$ArrowSprite.rotation = PI
	arrow.direction = $ArrowSprite.position.normalized()


#func _input(event):
#	if event is InputEventMouseButton:
#		move(event.position, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
