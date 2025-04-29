extends Area3D
#USAGE
#--This general use Area3D script can be used for any DeathZone node
#1. Upon adding a deathzone instance to a scene, connect the 
#'destroy_spring' signal to the _on_destroy_spring method of the spring CharacterBody3D.

#-- To use this DeathZone for a visible "hazard" asset:
#1. Make new scene w/3D node, import asset with root type Area3D
#2. Make asset local and delete 3D node 
#3. Generate a collisionshape for the imported mesh
#4. Delete the staticBody3D node
#5. Make the generated mesh collision a direct child of the Area3D
#6. Attach this script to the Area3D

#Stores the path of the spring node so that the area can check whether the spring overlaps it
@onready var spring = get_node("%TestSpring")

signal destroy_spring	#signal sent to the spring script to tell the spring to reset
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		destroy_spring.emit()
