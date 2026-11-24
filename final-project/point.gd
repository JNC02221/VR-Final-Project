extends RigidBody3D

signal scored(total_score: int)

@export var score_cooldown: float = 0.5   # seconds before the ball can score again

var score: int = 0
var can_score: bool = true


func _ready():
	# Required for contact signals to work
	contact_monitor = true
	max_contacts_reported = 4
	#body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node):
	print(body.name)
	if body.name == "Hoop" and can_score:
		score += 1
		print("Score: ", score)
		scored.emit(score)

		can_score = false
		await get_tree().create_timer(score_cooldown).timeout
		can_score = true
