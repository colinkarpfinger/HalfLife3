extends AnimatedSprite

func _on_AnimatedSprite_animation_finished():
	print("DONE!")
	queue_free()

	pass # Replace with function body.
