extends XRController3D

@export var throw_multiplier: float = 5
@export var velocity_samples: int = 6

@onready var grab_area: Area3D = $Area3D
@onready var ball: RigidBody3D = $"../../WorldEnvironment/Ball"

var held_body: RigidBody3D = null
var candidate_body: RigidBody3D = null

var last_pos: Vector3
var velocity_history: Array[Vector3] = []
var v: Vector3


func _ready():
	last_pos = global_position


func _physics_process(delta):
	# Track hand velocity (world space), keep a short rolling history
	v = (global_position - last_pos) / delta
	last_pos = global_position
	velocity_history.append(v)
	if velocity_history.size() > velocity_samples:
		velocity_history.pop_front()

	# Carry the held ball with the hand
	if held_body:
		held_body.global_position = grab_area.global_position
		
	if ball.global_position.x > global_position.x + 15 or ball.global_position.z > global_position.z + 15:
		ball.global_position = global_position
		ball.linear_velocity = Vector3(0,0,0)
		
	if ball.global_position.x < global_position.x - 15 or ball.global_position.z < global_position.z - 15:
		ball.global_position = global_position
		ball.linear_velocity = Vector3(0,0,0)
		
	var distance := global_position.distance_to(ball.global_position)
	print(distance)

func _get_throw_velocity() -> Vector3:
	if velocity_history.is_empty():
		return Vector3.ZERO
	var total := Vector3.ZERO
	for v in velocity_history:
		total += v
	return (total / velocity_history.size()) * throw_multiplier


func _on_body_entered(body):
	if body is RigidBody3D:
		candidate_body = body


func _on_body_exited(body):
	if body == candidate_body:
		candidate_body = null


func _on_button_pressed(button_name: String):
	if button_name == "grip_click" and candidate_body:
		held_body = candidate_body
		held_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		held_body.freeze = true
		held_body.linear_velocity = Vector3.ZERO
		held_body.angular_velocity = Vector3.ZERO
		
	if button_name == 'trigger':
		ball.global_position = global_position


func _on_button_released(button_name: String):
	if button_name == "grip_click" and held_body:
		var ball := held_body
		held_body = null

		var throw_velocity := _get_throw_velocity()

		ball.freeze = false
		ball.linear_velocity = throw_velocity

		# Re-apply after the physics server has processed the unfreeze
		await get_tree().physics_frame
		if is_instance_valid(ball):
			ball.linear_velocity = throw_velocity
