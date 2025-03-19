extends Node3D

#This code could be better it works for now though
@onready var compass: MeshInstance3D = $Cube
var target = Vector3()

func _ready():
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_pressed("show_compass"):
		visible = true
	else:
		visible = false
		
	#Calculate the direction from the pointer to the target
	var direction_to_target = (target - compass.global_transform.origin).normalized()
	
	var angle_y = atan2(direction_to_target.x, direction_to_target.z)
	
	compass.rotation_degrees.y = rad_to_deg(angle_y) - 90
	
func _on_target_target_pos(target_position: Variant) -> void:
	#receives compass target location from signal in script attached to target
	target = target_position

func _on_test_spring_spring_pos(spring_pos_x: Variant, spring_pos_y: Variant, spring_pos_z: Variant) -> void:
	position = Vector3(spring_pos_x, spring_pos_y + 1.5, spring_pos_z)
