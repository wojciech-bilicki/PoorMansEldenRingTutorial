extends Node

class_name InteractionHandler

var interactable 

const INTERACTION_ONE_SHOT_REQUEST = "parameters/OneShotInteraction/request"

@onready var inventory_ui = $"../InventoryUI" as InventoryUI
@onready var interaction_ui = $"../InteractionUI" as InteractionUI
@onready var animation_tree = $"../AnimationTree"

func toggle_interaction(is_enabled: bool, interactable):
	if is_enabled:
		interaction_ui.set_interaction_label_text("Press F to interact")
	else:
		interaction_ui.hide()
	if interactable && interactable.has_signal("picked_up") && !interactable.picked_up.is_connected(on_item_pickup):
		interactable.picked_up.connect(on_item_pickup)
		print_debug("connect")
	elif self.interactable && self.interactable.has_signal("picked_up") && self.interactable.picked_up.is_connected(on_item_pickup):
		self.interactable.picked_up.disconnect(on_item_pickup)
		print_debug("disconnect")
	self.interactable = interactable


func _input(event):
	if Input.is_action_just_pressed("interact"):
	
		if interactable && interactable.has_method("interact"):
			interactable.interact()
			animation_tree.set(INTERACTION_ONE_SHOT_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func clear_interactable():
	if interactable:
		interactable.queue_free()		

func on_item_pickup(item):
	inventory_ui.add_item(item)
