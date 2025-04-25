extends Control

@onready var intro_video = get_node("$Intro_Video_Player")

func _on_button_pressed():
	intro_video.play()
	
func _process(_float) -> void:
	if Input.is_action_pressed("skip"):
		get_tree().change_scene_to_file("res://Scenes/Levels/tutorial.tscn")
