extends Control

@onready var intro_video = get_node("%Intro_Video_Player")
@onready var credits = get_node("credits")

func _on_button_pressed():
	credits.hide()
	intro_video.show()
	intro_video.play()
	
func _process(_float) -> void:
	if Input.is_action_pressed("skip"):
		get_tree().change_scene_to_file("res://Scenes/Levels/tutorial.tscn")
		
#Built in signal for when a video ends
func _on_intro_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial.tscn")
