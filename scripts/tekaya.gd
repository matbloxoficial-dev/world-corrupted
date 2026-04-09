extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.12
const DASH_COOLDOWN = 0.8

const MAX_HP = 80
const INVENCIBILITY_TIME = 0.67

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var facing = 1

var hp = MAX_HP
var is_invencible = false
var invencibility_timer = 0.0

func _physics_process(delta: float) -> void:
	
	# Temporizadores del dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Invencibilidad
	if is_invencible:
		invencibility_timer -= delta
		if invencibility_timer <= 0:
			is_invencible = false
			modulate.a = 1.0



	# Gravedad
	if not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta

	# Dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		velocity.x = DASH_SPEED * facing
		velocity.y = 0

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento horizontal
	if not is_dashing:
		var direction = Input.get_axis("move_left", "move_right")

		if direction != 0:
			facing = 1 if direction > 0 else -1
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func recibir_danio(cantidad: int) -> void:
	if is_invencible:
		return

	hp -= cantidad
	print("HP: ", hp, " / ", MAX_HP)

	if hp <= 0:
		morir()
		return

	# Activa invencibilidad y parpadeo
	is_invencible = true
	invencibility_timer = INVENCIBILITY_TIME
	_parpadear()

func _parpadear() -> void:
	modulate.a = 0.4

func morir() -> void:
	print("Tekaya ha muerto")
	# Por ahora solo lo imprimimos, luego agregamos pantalla de muerte
	queue_free()
