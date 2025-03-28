extends Area3D
#USAGE
#--This general use area script can be edited for any DeathZone node
#1. Upon adding a checkpoint instance to a scene, connect the 
#'destroy_spring' signal to the _on_cp_pos method of the spring CharacterBody3D.

var spring	#This stores the path of the spring node 
			#so that the area can check whether the spring overlaps it
signal destroy_spring

func _ready() -> void:
	#warning: Messing with the tree hierarchy above SpringStuff may break this :[
	#to fix, recopy spring path by dragging the Spring node into the script path area (remove $)
	spring = get_node("../../../SpringStuff/TestSpring")
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		destroy_spring.emit()
