extends Area3D

#This general use area script can be edited for any area3D node.
#Upon adding a checkpoint instance to a scene, connect the 
#'cp_pos' signal to the _on_cp_pos method of the spring CharacterBody3D.

var respawn_pos = Vector3(0, 20, 0)		#This controls where the spring will respawn
										#if the spring enters this area

var spring	#This stores the path of the spring node 
			#so that the area can check whether the spring overlaps it
			#my only worry is whether this constant check impacts performance
signal cp_pos(cp_position)

func _ready() -> void:
	#warning: Messing with the tree hierarchy above SpringStuff may break this :[
	#to fix, recopy spring path by dragging the Spring node into the script path area (remove $)
	spring = get_node("../../../SpringStuff/TestSpring")
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		cp_pos.emit(respawn_pos)
