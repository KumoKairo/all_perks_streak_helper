extends ColorRect

@export var tween_speed: float = 1

func show_text(text):
	modulate = Color.TRANSPARENT
	$Timer.stop()
	show()
	$Label.text = text
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, tween_speed).set_ease(Tween.EASE_OUT)
	$Timer.start()


func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, tween_speed).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)
