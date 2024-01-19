extends SubViewport


@export var mesh_to_snapshot: ArrayMesh
@export var snapshot_name: String

@onready var mesh_instance_3d = $Node3D/MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():	
	print_debug(mesh_to_snapshot)
	print_debug(mesh_instance_3d)
	mesh_instance_3d.mesh = mesh_to_snapshot
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	var image_path = "Assets/Inventory/%s.png" % snapshot_name
	img.save_png(image_path)


