extends Node3D
#USAGE - for importing compass into new scene
#If you are importing the compass and a ship part into a new scene, 
#you must hook up 2 signals before the compass will point to a ship part.
#1. Connect spring_pos signal from spring_script.gd to _on_test_spring_spring_pos in this script
#2. Connect target_pos signal from target.gd to _on_ship_part_target_pos in this script

@onready var compass: MeshInstance3D = $Cube
var target = Vector3()

func _ready():
	visible = false						#hides compass on startup

func _process(_delta: float) -> void:
	#print("compass.gd _process")
	#Determine whether compass is shown to the player from input
	if Input.is_action_pressed("show_compass"):
		visible = true
	else:
		visible = false
		
	#Calculate the direction from the pointer to the target
	var direction_to_target = (target - compass.global_transform.origin).normalized()
	var angle_y = atan2(direction_to_target.x, direction_to_target.z)
	compass.rotation_degrees.y = rad_to_deg(angle_y) - 90		#rotate compass mesh accordingly
	
func _on_ship_part_target_pos(target_position: Variant) -> void:
	#print("compass.gd _on_ship_part_target_pos")
	target = target_position

func _on_test_spring_spring_pos(spring_pos_x: Variant, spring_pos_y: Variant, spring_pos_z: Variant) -> void:
	#print("compass.gd _on_test_spring_spring_pos")
	position = Vector3(spring_pos_x, spring_pos_y + 1.5, spring_pos_z)
