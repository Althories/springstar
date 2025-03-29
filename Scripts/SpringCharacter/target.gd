extends MeshInstance3D
#Used in compass functionality. From compass.gd:
#2. Connect target_pos signal from target.gd to _on_ship_part_target_pos in compass.gd

signal target_pos(target_position)		#sends target position for compass to point to

func _process(_delta: float) -> void:
	target_pos.emit(position)
