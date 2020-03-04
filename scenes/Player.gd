extends KinematicBody2D

# Declare member variables here. Examples:
const RUN_SPEED = 200
const GRAVITY := 20
const JUMP_SPEED = -600
const FLOOR = Vector2(0, -1)
var attack_count = 0
var onattack = false
var frames_next_attack = 0
var velocity = Vector2()
var onground = false
var jump_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("draw")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frames_next_attack > 0:
		frames_next_attack+=1
		if frames_next_attack > 52:
			frames_next_attack = 0
			attack_count = 0

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_attack"):
		attack()
	elif Input.is_action_just_pressed("ui_bow_attack"):
		bowAttack()
		
	if Input.is_action_pressed("ui_left") && ((onground && !onattack) or !onground):
		velocity.x = -RUN_SPEED
		$AnimatedSprite.flip_h = true
		$Sword/Collision.position.x = abs($Sword/Collision.position.x) * -1
		if onground and !onattack:
			$AnimatedSprite.animation = "runwpn"
	elif Input.is_action_pressed("ui_right") && ((onground && !onattack) or !onground):
		velocity.x = RUN_SPEED
		$AnimatedSprite.flip_h = false
		$Sword/Collision.position.x = abs($Sword/Collision.position.x)
		if onground and !onattack:
			$AnimatedSprite.animation = "runwpn"
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("ui_jump") && onground && !onattack:
		velocity.y = JUMP_SPEED
		onground = false
		jump_count = 1
		$AnimatedSprite.animation = "jump"
		
	if velocity.x == 0 && onground && !onattack:
		$AnimatedSprite.animation = "idlesword"
	
	velocity.y += GRAVITY
	
	if is_on_floor():
		onground = true
		jump_count = 0
		if $AnimatedSprite.animation == "airloopattack":
			$AnimatedSprite.animation = "airattack3"
	else:
		onground = false
		if velocity.y > 0 && !onattack:
			$AnimatedSprite.animation = "fall"
	
	velocity = move_and_slide(velocity, FLOOR)

func attack():
	if !onattack:
		$Sword.get_node("Collision").disabled = false
		attack_count += 1
		onattack = true
		if onground:
			$AnimatedSprite.animation = "attack"+str(attack_count)
		else:
			if attack_count < 3:
				$AnimatedSprite.animation = "airattack"+str(attack_count)
			else:
				$AnimatedSprite.animation = "airloopattack"
				
	if attack_count == 3:
		attack_count = 0

func bowAttack():
	if !onattack:
		onattack = true
		if onground:
			$AnimatedSprite.animation = "bowattack"
		else:
			$AnimatedSprite.animation = "bowattackjump"

func endAttack():
	onattack = false
	frames_next_attack = 1
	$Sword.get_node("Collision").disabled = true

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation.begins_with("attack") or $AnimatedSprite.animation == "bowattack":
		$AnimatedSprite.animation = "idlesword"
		endAttack()
	if $AnimatedSprite.animation.begins_with("airattack") or $AnimatedSprite.animation == "bowattackjump":
		$AnimatedSprite.animation = "fall"
		endAttack()




func _on_Sword_body_entered(body):
	if body.is_class("Enemy"):
		body.die()
