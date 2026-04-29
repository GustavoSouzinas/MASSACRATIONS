extends CollisionShape3D


func _on_body_entered(body: Node):
	
	if body.is_in_group("inimigos"):
		print("Acertei um inimigo!")
