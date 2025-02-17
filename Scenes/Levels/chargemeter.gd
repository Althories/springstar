extends TextureProgressBar

@export var spring: CharacterBody3D  

func _ready():
	visible = false
	spring.charging.connect(update) 
	update() 

func update():
	value = (spring.charge_velocity / 18.0) * max_value  # Scale charge % for UI
	
func _process(float):
	if Input.is_action_pressed("jump"):
		visible = true
	else: 
		visible = false
