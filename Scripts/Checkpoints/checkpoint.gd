extends Area3D
#USAGE
#--This general use area script can be edited for any area3D node.
#Upon adding a checkpoint instance to a scene, connect the 
#'cp_pos' signal to the _on_cp_pos method of the spring CharacterBody3D.
#--To edit the checkpoint collision, right click on the Checkpoint Area3D and select
#'Make Local'
#--To edit spring respawn location, change the position of the Checkpoint mesh.

#I don't think that's a thing (tragic) so maybe I can use an export var instead??
#Like, fetch position of something in the checkpoint node and make the player respawn there
var respawn_pos = Vector3(0, 0, 0)		#This controls where the spring will respawn
										#if the spring enters this area
var spring	#This stores the path of the spring node 
			#so that the area can check whether the spring overlaps it
			#my only worry is whether this constant check impacts performance
var respawn_mesh	#Initialized to fetch position of spring mesh 
					#sends respawn position to spring script
signal cp_pos(cp_position)

func _ready() -> void:
	#warning: Messing with the tree hierarchy above SpringStuff may break this :[
	#to fix, recopy spring path by dragging the Spring node into the script path area (remove $)
	
	#issue: The script doesn't wanna play ball
	#it will only get one instance
	spring = get_node("../../../SpringStuff/TestSpring")
	respawn_mesh = get_node("Checkpoint_Respawn_Pos")
	respawn_pos = respawn_mesh.global_position	#fetches objective mesh position in world
	
func _process(_delta: float) -> void:
	if overlaps_body(spring):
		cp_pos.emit(respawn_pos)
