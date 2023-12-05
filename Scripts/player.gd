extends CharacterBody3D

class_name Player

enum MovementMode {
	FOCUSED,
	UNFOCUSED
}

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var input: Vector2
var current_velocity: Vector2
var current_state_playback_path
var jump_queued = false
var falling = false

#exports
@export var move_speed = 30
@export var acceleration = 15
@export var locomotion_animation_transition_speed = 0.15
@export var direction_change_factor = 5
@export var movement_mode: MovementMode = MovementMode.UNFOCUSED
@export var focused_locomotion_state_playback_path: String
@export var unfocused_locomotion_state_playback_path: String
@export var jump_force = 150

#node references 
@onready var spring_arm_3d = $SpringArm3D
@onready var animation_tree = $AnimationTree
@onready var rig = $Rig

func _ready():
	switch_movement_mode()

func switch_movement_mode():
	var transition = "focused" if movement_mode == MovementMode.FOCUSED else "unfocused"
	current_state_playback_path = focused_locomotion_state_playback_path if movement_mode == MovementMode.FOCUSED else unfocused_locomotion_state_playback_path
	animation_tree.set("parameters/Transition/transition_request", transition)

func _process(delta):
	var velocityDelta = (input - current_velocity)
	if velocityDelta.length() > locomotion_animation_transition_speed:
		velocityDelta = velocityDelta.normalized() * locomotion_animation_transition_speed
	
	current_velocity += velocityDelta
	var animation_velocity = current_velocity
	animation_velocity.y *= -1

	if movement_mode == MovementMode.UNFOCUSED:
		var velocity_value = maxf(absf(animation_velocity.x), absf(animation_velocity.y))
		animation_tree.set("parameters/UnfocusedLocomotionStateMachine/UnfocusedLocomotion/blend_position", velocity_value)
	else:
		animation_tree.set("parameters/FocusedLocomotionStateMachine/BlendSpace2D/blend_position", animation_velocity)
	
func _physics_process(delta):
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
	if movement_mode == MovementMode.UNFOCUSED && velocity.length() > 0.01:
		rig.rotation.y = lerp_angle(rig.rotation.y, -atan2(velocity.x, -velocity.z), delta * direction_change_factor)
	elif velocity.length() > 0.01 && movement_mode == MovementMode.FOCUSED:
		rig.rotation.y = lerp_angle(rig.rotation.y, spring_arm_3d.rotation.y, delta * direction_change_factor)
		
func get_input(delta):
	var vy = velocity.y
	velocity.y = 0
	input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm_3d.rotation.y)
	velocity = lerp(velocity, move_speed * dir, delta * acceleration) 
	velocity.y = vy

func _input(event):
	if Input.is_action_just_pressed("focus"):
		movement_mode = MovementMode.FOCUSED if movement_mode == MovementMode.UNFOCUSED else MovementMode.UNFOCUSED
		switch_movement_mode()
	if Input.is_action_just_pressed("jump"):
		begin_jump()

func begin_jump():
	var playback = animation_tree.get(current_state_playback_path)
	playback.travel("Jump_Start")

func apply_jump_velocity():
	jump_queued = true
