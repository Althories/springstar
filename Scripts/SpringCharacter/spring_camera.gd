extends Camera3D

var target_fov = 75.0		#default set in scene

func _input(event):
	if event.is_action_pressed("fov_up"):
		target_fov += 5
	if event.is_action_pressed("fov_down"):
		target_fov -= 5
	
func _process(_float) -> void:
	fov = lerp(fov, target_fov, .1)		#im lerping it ough
										#smooths fov from current to desired value by a certain rate from 0 to 1
