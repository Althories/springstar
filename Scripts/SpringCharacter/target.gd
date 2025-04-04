extends Node3D
#Used in compass functionality. From compass.gd:
#2. Connect target_pos signal from target.gd to _on_ship_part_target_pos in compass.gd

@onready var ship_area = get_node("Part/Ship_Area")
@onready var spring = get_node("../../SpringStuff/TestSpring")

signal target_pos(target_position)		#sends target position for compass to point to

func _process(_delta: float) -> void:
	print("target.gd _process")
	target_pos.emit(position)			#compass receives this so it can point to ship part
	
	if ship_area.overlaps_body(spring):
		get_tree().change_scene_to_file("res://Scenes/Levels/hub.tscn")
