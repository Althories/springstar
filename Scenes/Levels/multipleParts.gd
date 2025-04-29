extends Sprite2D

@onready var star1 = $star
@onready var star2 = $star2
@onready var star3 = $star3
@export var partLabel: Label

var remainingStars = 3

func _on_ship_part_collected(partNum: int) -> void:
	if partNum == 1:
		star1.visible = false
	elif partNum == 2:
		star2.visible = false
	elif partNum == 3:
		star3.visible = false
	remainingStars -= 1
	if remainingStars == 2:
		partLabel.text = "Only 2 more ship parts to collect!"
	elif remainingStars == 1:
		partLabel.text = "Only 1 more ship part to collect!"
	else:
		partLabel.text = "You've collected all the parts!\nThank you for playing our demo! <3"
	partLabel._on_show_cp_label(3,0)
	
