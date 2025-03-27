extends Area3D

var spring	#This stores the path of the spring node 
			#so that the area can check whether the spring overlaps it
			#my only worry is whether this constant check impacts performance

func _ready() -> void:
	spring = get_node("../SpringStuff/TestSpring")	#This will break if this changes (teehee)
	
func _process(_float) -> void:
	if overlaps_body(spring):
		print("spring REGISTERED")
