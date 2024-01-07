extends CanvasLayer

class_name InteractionUI

@onready var interaction_label = %InteractionLabel

func set_interaction_label_text(interaction_label_text: String):
	interaction_label.text = interaction_label_text
	visible = true
