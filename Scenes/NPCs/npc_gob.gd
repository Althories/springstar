extends StaticBody3D

@onready var Dialogue_Zone = get_node("Dialogue_Zone")
@onready var spring = get_node("../../../SpringStuff/TestSpring")

var dialogue_triggered = false		#lazy imp to keep dialogue from trying to start again

func _process(_delta: float) -> void:
	if Dialogue_Zone.overlaps_body(spring) and Input.is_action_pressed("enter_dialogue") and dialogue_triggered == false:
		dialogue_triggered = true
		Dialogic.start("test_timeline")
