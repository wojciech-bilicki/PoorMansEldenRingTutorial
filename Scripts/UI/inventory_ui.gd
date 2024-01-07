extends CanvasLayer

class_name InventoryUI

@onready var v_box_container = $MarginContainer/VBoxContainer

var items = []

func add_item(item: Item):
	items.append(item)
	create_item_label(item)
	
func create_item_label(item: Item):
	var label = Label.new()
	label.text = item.name
	v_box_container.add_child(label)
	
func toggle():
	visible = !visible
