extends Label
#Shows visual indicator for reaching a checkpoint
#The cp_label signal will send a signal to the checkpoint text/icon to appear.
#Connect Spring Script signal to this node

func _ready():
	hide()

func _on_show_cp_label(show_length = 1, buffer_length = 2) -> void:
	show()		
	await get_tree().create_timer(show_length).timeout 	#How long the timer shows
	hide()
	await get_tree().create_timer(buffer_length).timeout	#How long the timer will be hidden before showing again
