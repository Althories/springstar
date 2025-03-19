extends Node3D

@onready var compass: MeshInstance3D = $Cube
var target = Vector3()

func _process(delta: float) -> void:
	#Calculate the direction from the pointer to the target
	var direction_to_target = (target - compass.global_transform.origin).normalized()
	
	var angle_y = atan2(direction_to_target.x, direction_to_target.z)
	
	compass.rotation_degrees.y = rad_to_deg(angle_y) - 90
	
	
	


func _on_target_target_pos(target_position: Variant) -> void:
	target = target_position
	print(target_position)
