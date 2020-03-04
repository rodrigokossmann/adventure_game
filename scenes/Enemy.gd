extends KinematicBody2D

const GRAVITY = 10
const SPEED = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

var direction = 1
var died = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if !died:
		velocity.x = -SPEED * direction
		$AnimatedSprite.play("move")
		velocity.y += GRAVITY
		
		velocity = move_and_slide(velocity, FLOOR)
		
		if is_on_wall() or !$RayCast2D.is_colliding():
			direction *= -1
			$RayCast2D.position.x *= -1
			$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

func die():
	$AnimatedSprite.animation = "die"
	died = true
	
func get_class():
	return "Enemy"
	
func is_class(type):
	return get_class() == type

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die":
		get_parent().remove_child(self)
