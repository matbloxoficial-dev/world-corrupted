extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.12
const DASH_COOLDOWN = 0.8

const MAX_HP = 80
const INVENCIBILITY_TIME = 0.67

# Combate
const DANO_GOLPE = [10, 12, 18]
const DANO_CARGADO = 35
const TIEMPO_CARGA = 0.8
const VENTANA_COMBO = 0.5

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var facing = 1

var hp = MAX_HP
var is_invencible = false
var invencibility_timer = 0.0

var combo_paso = 0
var combo_timer = 0.0
var atacando = false
var ataque_timer = 0.0
var cargando = false
var carga_timer = 0.0

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

	# Combo timer — si pasa mucho tiempo sin atacar, reinicia
	if combo_paso > 0 and not atacando:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_paso = 0

	# Ataque timer — duración de cada golpe
	if atacando:
		ataque_timer -= delta
		if ataque_timer <= 0:
			atacando = false
			$Hitbox.monitoring = false
			$Hitbox.monitorable = false

	# Carga del ataque cargado
	if cargando:
		carga_timer += delta

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

	# Ataque — presionar
	if Input.is_action_just_pressed("attack") and not atacando:
		cargando = true
		carga_timer = 0.0

	# Ataque — soltar
	if Input.is_action_just_released("attack"):
		if cargando:
			if carga_timer >= TIEMPO_CARGA:
				_ejecutar_ataque_cargado()
			else:
				_ejecutar_combo()
			cargando = false
			carga_timer = 0.0

	# Movimiento horizontal
	if not is_dashing:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			facing = 1 if direction > 0 else -1
			$Sprite2D.flip_h = facing == -1
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _ejecutar_combo() -> void:
	atacando = true
	combo_timer = VENTANA_COMBO
	var dano = DANO_GOLPE[combo_paso]
	ataque_timer = 0.25

	# Activa hitbox
	$Hitbox.monitoring = true
	$Hitbox.monitorable = true

	print("Golpe ", combo_paso + 1, " — daño: ", dano)

	combo_paso += 1
	if combo_paso >= 3:
		combo_paso = 0

func _ejecutar_ataque_cargado() -> void:
	atacando = true
	ataque_timer = 0.4
	combo_paso = 0

	$Hitbox.monitoring = true
	$Hitbox.monitorable = true

	print("Ataque CARGADO — daño: ", DANO_CARGADO)

func recibir_danio(cantidad: int) -> void:
	if is_invencible:
		return

	hp -= cantidad
	print("HP: ", hp, " / ", MAX_HP)

	if hp <= 0:
		morir()
		return

	is_invencible = true
	invencibility_timer = INVENCIBILITY_TIME
	modulate.a = 0.4

func morir() -> void:
	print("Tekaya ha muerto")
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	pass

func _on_hitbox_body_entered(body: Node) -> void:
	if body.has_method("recibir_danio"):
		var dano = DANO_CARGADO if carga_timer >= TIEMPO_CARGA else DANO_GOLPE[max(combo_paso - 1, 0)]
		body.recibir_danio(dano)
