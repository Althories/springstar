extends Control

func _ready() -> void:
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("controls"):
		self.visible = not self.visible
