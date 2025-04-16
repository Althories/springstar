extends Label
#Shows visual indicator for reaching a checkpoint\
#Todo: Prevent 'checkpoint reached' message from repeating on the same checkpoint
#before reaching another checkpoint

func _ready():
	hide()

func _on_cp_label() -> void:
	show()		
	await get_tree().create_timer(1).timeout 	#How long the timer shows
	hide()
	await get_tree().create_timer(2).timeout	#How long the timer will be hidden before showing again
