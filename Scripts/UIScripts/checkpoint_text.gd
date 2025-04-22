extends Label
#Shows visual indicator for reaching a checkpoint
#The cp_label signal will send a signal to the checkpoint text/icon to appear.
#Connect Spring Script signal to this node

func _ready():
	hide()

func _on_show_cp_label() -> void:
	show()		
	await get_tree().create_timer(1).timeout 	#How long the timer shows
	hide()
	await get_tree().create_timer(2).timeout	#How long the timer will be hidden before showing again
