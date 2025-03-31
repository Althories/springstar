extends StaticBody3D

#Connect dialogue_running script to _on_dialogue_running in Spring script

@onready var Dialogue_Zone = get_node("Dialogue_Zone")
@onready var spring = get_node("../../SpringStuff/TestSpring")

var intro_played = false				#lazy imp to track when intro dialogue ends

func _ready() -> void:
	Dialogic.signal_event.connect(_on_intro_end)

func _process(_delta: float) -> void:
	#If spring is near Gob + Dialogue button pressed + No timeline currently runnning
	if Dialogue_Zone.overlaps_body(spring) and Input.is_action_pressed("enter_dialogue") and Dialogic.current_timeline == null:
		if intro_played == false:				#if intro dialogue has yet to run
			Dialogic.start("Guario-Intro")
		else:
			Dialogic.start("Guario-Looping")

func _on_intro_end(argument: String):	#Sent at end of intro timeline.
	if argument == "end_intro":
		intro_played = true
