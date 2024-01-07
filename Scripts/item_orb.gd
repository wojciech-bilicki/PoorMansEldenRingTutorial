extends Node3D

class_name ItemOrb

const GRADIENT_OFFSET_1 = 0.14
const GRADIENT_OFFSET_2 = 0.68

signal picked_up(item: Item)

@export var color: Color
@export var item: Item

@onready var gpu_particles_3d = $GPUParticles3D

func _ready():	
	setup_particle_materials(color)
	
func setup_particle_materials(color: Color):
	var draw_pass_material = gpu_particles_3d.draw_pass_1.material.duplicate()
	draw_pass_material.albedo_color = color
	gpu_particles_3d.draw_pass_1.material = draw_pass_material
	
	var process_material = gpu_particles_3d.process_material.duplicate()
	process_material.color = color
	
	var color_gradient = Gradient.new()
	color_gradient.add_point(GRADIENT_OFFSET_1, Color.BLACK)
	color_gradient.add_point(GRADIENT_OFFSET_2, color)
	process_material.color_initial_ramp = color_gradient	
	gpu_particles_3d.process_material = process_material


func _on_area_3d_body_entered(body):
	if body is Player:
		print("enter")
		(body as Player).interaction_handler.toggle_interaction(true, self)


func _on_area_3d_body_exited(body):
	if body is Player:
		print("exit")
		(body as Player).interaction_handler.toggle_interaction(false, null)


func interact():
	print_debug("signal interact")
	picked_up.emit(item)
