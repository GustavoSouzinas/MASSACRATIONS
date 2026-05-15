extends Node3D

func _ready():
	$AnimationPlayer.play("mixamo_com")
	$AnimationPlayer.speed_scale = 1.0
