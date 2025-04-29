extends TextureProgressBar

@export var spring: CharacterBody3D  

func _ready():
	visible = false
	spring.charging.connect(update) 
	update() 

func update():
	value = (spring.charge_velocity / 18.0) * max_value  # Scale charge % for UI
	
func _process(_float):
	if Input.is_action_pressed("jump") and spring.is_on_floor():
		await get_tree().create_timer(0.2).timeout
		visible = true
	else: 
		visible = false
