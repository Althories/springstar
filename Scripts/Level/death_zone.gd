extends Area3D
#USAGE
#--This general use Area3D script can be used for any DeathZone node
#1. Upon adding a deathzone instance to a scene, connect the 
#'destroy_spring' signal to the _on_destroy_spring method of the spring CharacterBody3D.

#-- To use this DeathZone for a visible "hazard" asset:
#1. Import the mesh you want to use for the deathzone
#2. Generate a collisionshape for the imported mesh
#3. Delete the staticBody3D node
#4. Make the generated mesh collision a direct child of the DeathZone node

#warning: Messing with the tree hierarchy above SpringStuff may break this path
#to fix, recopy spring path by dragging the Spring node into the script path area (remove $)
#Stores the path of the spring node so that the area can check whether the spring overlaps it
@onready var spring = get_node("%TestSpring")

signal destroy_spring	#signal sent to the spring script to tell the spring to reset
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		destroy_spring.emit()
