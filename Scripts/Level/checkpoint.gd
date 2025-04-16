extends Area3D
#USAGE
#--This general use script can be applied to any Checkpoint node
#1. Upon adding a checkpoint instance to a scene, connect the 
#'cp_pos' signal to the _on_cp_pos method of the spring CharacterBody3D.
#--To edit spring respawn location, change the position of the Checkpoint Area3D node.
#The mesh is meant to be a visual aid and nothing more.
#--To edit the checkpoint collision, right click on the Area3D and select
#'Make Local', then edit collision bounds

#The cp_label signal will send a signal to the checkpoint text/icon to appear.
#Connect it to the Checkpoint Labl node in the scene.

#warning: Messing with the tree hierarchy above SpringStuff may break the path
#to fix, recopy spring path by dragging the Spring node into the script path area (remove $)
#Stores the path of the spring node 
#so that overlaps_body() can check for the spring
@onready var spring = get_node("../../../SpringStuff/TestSpring")	#This path must be consistent across all scenes
@onready var respawn_pos = global_position		#Global position of the Checkpoint Area3D

var most_recent_pos = respawn_pos	#Initializes to be first checkpoint in level

signal cp_pos(cp_position)		#Responsible for setting spring respawn position
signal cp_label					#Respobsible for displaying UI checkpoint indicator
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		if most_recent_pos != respawn_pos:	#If the checkpoint isn't the last checkpoint reached
			cp_label.emit()					#Emit text indicator
		cp_pos.emit(respawn_pos)
		most_recent_pos = respawn_pos	   #Updates after signal check
		
		
