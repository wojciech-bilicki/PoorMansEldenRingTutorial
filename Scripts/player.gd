extends CharacterBody3D

class_name Player

enum MovementMode {
	FOCUSED,
	UNFOCUSED
}

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var input: Vector2
var current_velocity: Vector2
var jump_queued = false
var falling = false
var process_input = true
var is_dodging

#exports
@export var move_speed = 15
@export var acceleration = 15
@export var locomotion_animation_transition_speed = 0.15
@export var direction_change_factor = 5
@export var current_state_playback_path: String
@export var movement_mode: MovementMode = MovementMode.UNFOCUSED

@export_group("Dodge Params")
@export var dodge_velocity = 25 
@export var dodge_back_velocity = 20
@export_group("")

@export var jump_force = 150

#node references 
@onready var spring_arm_3d = $SpringArm3D
@onready var animation_tree = $AnimationTree
@onready var rig = $Rig
@onready var interaction_handler = $InteractionHandler
@onready var inventory_ui = $InventoryUI as InventoryUI


func _ready():
	switch_movement_mode()
	inventory_ui.inventory_toggled.connect(on_inventory_toggled)

func switch_movement_mode():
	var enabled_parameter = "parameters/Locomotion/conditions/is_focused_animation_on" if movement_mode == MovementMode.FOCUSED else "parameters/Locomotion/conditions/is_unfocused_animation_on"
	var disabled_parameter = "parameters/Locomotion/conditions/is_unfocused_animation_on" if movement_mode == MovementMode.FOCUSED else "parameters/Locomotion/conditions/is_focused_animation_on"
	var transition = "focused" if movement_mode == MovementMode.FOCUSED else "unfocused"
	
	animation_tree.set(enabled_parameter, true)
	animation_tree.set(disabled_parameter, false)
	
	var playback = animation_tree.get(current_state_playback_path) as AnimationNodeStateMachinePlayback
	var travel_name = "Unfocused_Locomotion" if movement_mode == MovementMode.UNFOCUSED else "Focused_Locomotion"

	playback.travel(travel_name)

func _process(delta):
	if !process_input:
		return
	var velocityDelta = (input - current_velocity)
	if velocityDelta.length() > locomotion_animation_transition_speed:
		velocityDelta = velocityDelta.normalized() * locomotion_animation_transition_speed
	
	current_velocity += velocityDelta
	var animation_velocity = current_velocity
	animation_velocity.y *= -1
	set_animation_blend_position(animation_velocity)


func set_animation_blend_position(animation_velocity: Vector2):	
	if movement_mode == MovementMode.UNFOCUSED:
		var velocity_value = maxf(absf(animation_velocity.x), absf(animation_velocity.y))
		animation_tree.set("parameters/Locomotion/Unfocused_Locomotion/blend_position", velocity_value)
	else:
		animation_tree.set("parameters/Locomotion/Focused_Locomotion/blend_position", animation_velocity)
	
func _physics_process(delta):
	if !process_input:
		return
	move_and_slide()

	get_input(delta)
	
	handle_rotation(delta)
	handle_jumping()
	
	

func handle_jumping():
	velocity.y -= gravity
	if !is_on_floor():
		jump_queued = false
		if !falling:
			falling = true
			var playback = animation_tree.get(current_state_playback_path) as AnimationNodeStateMachinePlayback
			playback.travel("Jump_Idle")
	elif falling:
		falling = false
		var playback = animation_tree.get(current_state_playback_path) as AnimationNodeStateMachinePlayback
		playback.travel("Jump_Land")
		
	if jump_queued:
		velocity.y = jump_force
		jump_queued = false
		falling = true		

func handle_rotation(delta):
	
	if is_dodging:
		return
	
	if movement_mode == MovementMode.UNFOCUSED && velocity.length() > 0.01 && is_on_floor():
		rig.rotation.y = lerp_angle(rig.rotation.y, -atan2(velocity.x, -velocity.z), delta * direction_change_factor)
	elif velocity.length() > 0.01 && movement_mode == MovementMode.FOCUSED:
		rig.rotation.y = lerp_angle(rig.rotation.y, spring_arm_3d.rotation.y, delta * direction_change_factor)
		
func get_input(delta):
	if is_dodging:
		return
	var vy = velocity.y
	velocity.y = 0
	input = Input.get_vector("left", "right", "forward", "back")

	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm_3d.rotation.y)
	velocity = lerp(velocity, move_speed * dir, delta * acceleration) 
	velocity.y = vy

func _input(event):
	if !process_input:
		return
	if Input.is_action_just_pressed("focus"):
		movement_mode = MovementMode.FOCUSED if movement_mode == MovementMode.UNFOCUSED else MovementMode.UNFOCUSED
		switch_movement_mode()
	if Input.is_action_just_pressed("jump"):
		begin_jump()
	if Input.is_action_just_pressed("dodge"):
		var movement_input =  Input.get_vector("left", "right", "forward", "back")
		dodge(movement_input)
		

func begin_jump():
	var playback = animation_tree.get(current_state_playback_path)
	playback.travel("Jump_Start")

func apply_jump_velocity():
	print_debug("apply_jump_velocity")
	jump_queued = true


func dodge(dir: Vector2):
	is_dodging = true
	var playback = animation_tree.get(current_state_playback_path)
	if movement_mode == MovementMode.UNFOCUSED:
		if dir == Vector2.ZERO:
			velocity = rig.transform.basis.z * dodge_back_velocity
			playback.travel("Dodge_Backward")
		else:
			velocity = -rig.transform.basis.z * dodge_velocity
			playback.travel("Dodge_Forward")
	else: 
		
		if dir == Vector2.ZERO:
			velocity = rig.transform.basis.z * dodge_back_velocity
			playback.travel("Dodge_Backward")
		elif dir == Vector2.LEFT:
			velocity = -rig.transform.basis.x * dodge_velocity
			playback.travel("Dodge_Left")
		elif dir == Vector2.RIGHT:
			velocity = rig.transform.basis.x * dodge_velocity
			playback.travel("Dodge_Right")
		elif dir == Vector2.DOWN:
			
			playback.travel("Dodge_Backward")
			velocity = rig.transform.basis.z * dodge_velocity
		elif dir == Vector2.UP:
			playback.travel("Dodge_Forward")
			velocity = -rig.transform.basis.z * dodge_velocity
	
func finish_dodge():
	is_dodging = false
	velocity = Vector3.ZERO

func on_inventory_toggled(is_shown: bool):
	
	process_input = !is_shown
	velocity = Vector3.ZERO
	set_animation_blend_position(Vector2.ZERO)
