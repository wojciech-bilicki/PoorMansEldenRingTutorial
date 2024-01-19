extends SpringArm3D

@export var mouse_sensitivity = 0.5
@export var min_x_degrees = -45
@export var max_x_degrees = 30

@onready var inventory_ui = $"../InventoryUI" as InventoryUI

var process_input = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inventory_ui.inventory_toggled.connect(on_inventory_toggled)

func _unhandled_input(event):
	if event is InputEventMouseMotion && process_input:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, min_x_degrees, max_x_degrees)
	
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360.0)

func on_inventory_toggled(is_shown: bool):
	process_input = !is_shown
