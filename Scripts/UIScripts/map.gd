extends Node2D

@onready var mapBG: ColorRect = $background
@onready var mapImage: Sprite2D = $background/map
@onready var charCursor: Sprite2D = $background/map/character

@export var character: CharacterBody3D
@export var POS_SCALE = 3.2

func _ready() -> void:
	mapBG.visible = false

func _physics_process(_float) -> void:
	charCursor.position = Vector2(character.position.x*POS_SCALE, character.position.z*POS_SCALE)
	charCursor.rotation = -character.rotation.y
	if Input.is_action_pressed("map"):
		mapBG.visible = true
	else:
		mapBG.visible = false
