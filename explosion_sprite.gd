extends AnimatedSprite3D

func _ready():
	play()

func _on_animated_sprite_3d_animation_finished():
	queue_free()
