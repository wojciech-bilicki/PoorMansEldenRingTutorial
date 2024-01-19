extends Node3D

@onready var inventory_ui = $"../InventoryUI" as InventoryUI


func _ready():
	inventory_ui.on_item_press.connect(item_pressed)
	
func item_pressed(mesh: Mesh, bone_attachment_node_name: String):
	var attachment_node = get_node("Skeleton3D/" + bone_attachment_node_name)
	if !attachment_node:
		return
	
	var meshInstance = MeshInstance3D.new()
	meshInstance.mesh = mesh
	attachment_node.add_child(meshInstance)
		
