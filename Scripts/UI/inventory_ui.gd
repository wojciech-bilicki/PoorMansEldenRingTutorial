extends CanvasLayer

class_name InventoryUI

signal inventory_toggled(is_shown: bool)
signal on_item_press(item: Mesh, bone_attachment_node_name: String)

const ITEM_PANEL_SCENE = preload("res://Scenes/item_panel.tscn")
@onready var left_hand_panel = %LeftHandPanel
@onready var right_hand_panel = %RightHandPanel
@onready var grid_container = %GridContainer


var items: Array[Item] = []
var visible_items: Array[Item] = []

func _ready():
	right_hand_panel.on_press.connect(on_right_hand_panel_press)
	left_hand_panel.on_press.connect(on_left_hand_panel_press)

func add_item(item: Item):
	items.append(item)

func toggle():
	visible = !visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	inventory_toggled.emit(visible)	

func on_right_hand_panel_press():
	
	clear_grid()
	visible_items = items.filter(func (i): return i.inventory_slot == Enums.InventorySlot.RightHand)
	show_item_in_a_grid(visible_items)
	
func on_left_hand_panel_press():
	clear_grid()
	visible_items = items.filter(func (i): return i.inventory_slot == Enums.InventorySlot.LeftHand)
	show_item_in_a_grid(visible_items)
	
func show_item_in_a_grid(items_to_show: Array[Item]):
	for item in visible_items:
		var item_panel = ITEM_PANEL_SCENE.instantiate()
		item_panel.label = item.name
		item_panel.texture = item.image
		item_panel.on_press.connect(on_inventory_item_press.bind(item.mesh, item.bone_attachment_name))
		grid_container.add_child(item_panel)

func on_inventory_item_press(mesh: Mesh, bone_attachment_node_name: String):
	on_item_press.emit(mesh, bone_attachment_node_name)

func clear_grid():
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
