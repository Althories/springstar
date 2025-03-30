extends Area3D
#USAGE

var dialogue_triggered = false		#lazy imp to keep dialogue from trying to start again

@onready var spring = get_node("SpringStuff/TestSpring")
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("enter_dialogue") and dialogue_triggered == false:
		dialogue_triggered = true
		Dialogic.start("test_timeline")
