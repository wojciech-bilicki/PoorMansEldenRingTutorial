extends Node

class_name InputManager

@onready var inventory_ui = $"../InventoryUI" as InventoryUI

func _input(event):
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.toggle()

		
