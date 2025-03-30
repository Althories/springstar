extends StaticBody3D

@onready var Dialogue_Zone = get_node("Dialogue_Zone")
@onready var spring = get_node("../../../SpringStuff/TestSpring")

var dialogue_triggered = false		#lazy imp to keep dialogue from trying to start again
var intro_over = false				#lazy imp to track when intro dialogue ends
var loop_over = true				#plays the first time, waits on dialogic signal successive times

func _ready() -> void:
	Dialogic.signal_event.connect(_on_intro_end)
	Dialogic.signal_event.connect(_on_looping_end)

func _process(_delta: float) -> void:
	
	#If spring is near Gob + Dialogue button pressed
	if Dialogue_Zone.overlaps_body(spring) and Input.is_action_pressed("enter_dialogue"):
		if dialogue_triggered == false:
			dialogue_triggered = true
			Dialogic.start("Gob-Intro")
		if intro_over == true and loop_over == true:
			loop_over = false
			Dialogic.start("Gob-Looping")

func _on_intro_end(argument: String):
	if argument == "end_intro":
		intro_over = true
		
func _on_looping_end(argument: String):
	if argument == "end_loop":
		loop_over = true
		
	
