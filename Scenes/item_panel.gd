extends Panel

class_name ItemPanel

signal on_press

@export var label: String
@export var texture: Texture
@onready var texture_rect = %TextureRect

@onready var item_label = %ItemLabel

@onready var button = %Button

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture = texture
	item_label.text = label
	button.pressed.connect(on_button_press)


func on_button_press():
	on_press.emit()
