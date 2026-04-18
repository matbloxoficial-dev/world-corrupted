extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.12
const DASH_COOLDOWN = 0.8
const DANO_PATADA = 14
const COOLDOWN_PATADA = 3.0
const EXP_POR_NIVEL = [0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700, 
						3250, 3850, 4500, 5200, 5950, 6750, 7600, 8500, 9450, 10450]
const INVENCIBILITY_TIME = 0.67

# Combate
const DANO_GOLPE = [10, 12, 18]
const DANO_CARGADO = 35
const TIEMPO_CARGA = 0.8
const VENTANA_COMBO = 0.5

@onready var anim = $Visual/AnimatedSprite2D

var SPEED_MODIFICADOR = 1.0
var hurt_timer = 0.0
var esencia_equipada_1: EsenciaBase = null
var esencia_equipada_2: EsenciaBase = null
var equipo_arma: Equipo = null
var equipo_armadura: Equipo = null
var equipo_accesorio: Equipo = null
var nivel = 1
var exp = 0
var punto_reaparicion = Vector2.ZERO
var hud = null
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var facing = 1
var patada_cooldown = 0.0

var corrupcion = 0
var MAX_HP = 80
var hp = MAX_HP
var is_invencible = false
var invencibility_timer = 0.0

var combo_paso = 0
var combo_timer = 0.0
var atacando = false
var ataque_timer = 0.0
var cargando = false
var carga_timer = 0.0
var ralentizacion_timer = 0.0

func aplicar_ralentizacion(duracion: float) -> void:
	SPEED_MODIFICADOR = 0.4
	ralentizacion_timer = duracion
	print("Tekaya ralentizado")
	
func _physics_process(delta: float) -> void:
	
	# Usar esencia
	if Input.is_action_just_pressed("use_essence") and esencia_equipada_1:
		esencia_equipada_1.habilidad_1(self)

	if esencia_equipada_1 and esencia_equipada_1.activa:
		esencia_equipada_1.pasiva(self, delta)

	# Timers
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if ralentizacion_timer > 0:
		ralentizacion_timer -= delta
		if ralentizacion_timer <= 0:
			SPEED_MODIFICADOR = 1.0
			print("Velocidad restaurada")

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if patada_cooldown > 0:
		patada_cooldown -= delta

	# Invencibilidad
	if is_invencible:
		invencibility_timer -= delta
		if invencibility_timer <= 0:
			is_invencible = false
			modulate.a = 1.0

	# Combo
	if combo_paso > 0 and not atacando:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_paso = 0

	# Ataque timer
	if atacando:
		ataque_timer -= delta
		if ataque_timer <= 0:
			atacando = false
			$Visual/Hitbox.monitoring = false
			$Visual/Hitbox.monitorable = false

	# Carga
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

	# Ataque presionar
	if Input.is_action_just_pressed("attack") and not atacando:
		cargando = true
		carga_timer = 0.0

	# Ataque soltar
	if Input.is_action_just_released("attack"):
		if cargando:
			if carga_timer >= TIEMPO_CARGA:
				_ejecutar_ataque_cargado()
			else:
				_ejecutar_combo()
			cargando = false
			carga_timer = 0.0

	# Movimiento
	if not is_dashing and not atacando:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			facing = 1 if direction > 0 else -1
			$Visual.scale.x = facing
			velocity.x = direction * SPEED * SPEED_MODIFICADOR
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Patada
	if Input.is_action_just_pressed("kick") and patada_cooldown <= 0 and not atacando:
		_ejecutar_patada()
		
	if Input.is_action_just_pressed("save_game"):
		SaveManager.guardar(self)
	
	if Input.is_action_just_pressed("load_game"):
		SaveManager.cargar(self)
		if hud:
			hud.actualizar_hp(hp, MAX_HP)
	move_and_slide()

	if hurt_timer > 0:
		hurt_timer -= delta
		return
	# ANIMACIONES
	var anim_actual = anim.animation

	if is_dashing:
		if anim_actual != "dash":
			anim.play("dash")
		return

	if atacando:
		if patada_cooldown > COOLDOWN_PATADA - 0.3:
			if anim_actual != "kick":
				anim.play("kick")
		else:
			if anim_actual != "attack":
				anim.play("attack")
		return

	if not is_on_floor():
		if anim_actual != "jump":
			anim.play("jump")
	elif abs(velocity.x) > 10:
		if anim_actual != "run":
			anim.play("run")
	else:
		if anim_actual != "idle":
			anim.play("idle")


func _ejecutar_combo() -> void:
	atacando = true
	combo_timer = VENTANA_COMBO
	var dano = DANO_GOLPE[combo_paso]
	ataque_timer = 0.25

	$Visual/Hitbox.monitoring = true
	$Visual/Hitbox.monitorable = true

	print("Golpe ", combo_paso + 1, " — daño: ", dano)

	combo_paso += 1
	if combo_paso >= 3:
		combo_paso = 0


func _ejecutar_ataque_cargado() -> void:
	atacando = true
	ataque_timer = 0.4
	combo_paso = 0

	$Visual/Hitbox.monitoring = true
	$Visual/Hitbox.monitorable = true

	print("Ataque CARGADO — daño: ", DANO_CARGADO)


func _ejecutar_patada() -> void:
	patada_cooldown = COOLDOWN_PATADA
	atacando = true
	ataque_timer = 0.3

	$Visual/Hitbox.monitoring = true
	$Visual/Hitbox.monitorable = true

	print("Patada giratoria — daño: ", DANO_PATADA)


func recibir_danio(cantidad: int) -> void:
	if is_invencible:
		return

	hp -= cantidad
	print("HP: ", hp, " / ", MAX_HP)

	if hud:
		hud.actualizar_hp(hp, MAX_HP)

	if hp <= 0:
		morir()
		return

	is_invencible = true
	invencibility_timer = INVENCIBILITY_TIME
	modulate.a = 0.4
	anim.play("hurt")
	hurt_timer = 0.4


func morir() -> void:
	anim.play("death")
	set_physics_process(false)
	await get_tree().create_timer(1.2).timeout

	if punto_reaparicion != Vector2.ZERO:
		hp = MAX_HP / 2
		global_position = punto_reaparicion
		set_physics_process(true)
		if hud:
			hud.actualizar_hp(hp, MAX_HP)
	else:
		get_tree().reload_current_scene()


func _on_hitbox_body_entered(body: Node) -> void:
	if body == self:
		return

	if body.has_method("recibir_danio"):
		var bono = equipo_arma.bono_danio if equipo_arma else 0
		var dano: int

		if patada_cooldown > COOLDOWN_PATADA - 0.3:
			dano = DANO_PATADA + bono
		elif carga_timer >= TIEMPO_CARGA:
			dano = DANO_CARGADO + bono + (nivel * 2)
		else:
			dano = DANO_GOLPE[max(combo_paso - 1, 0)] + bono + (nivel * 2)

		body.recibir_danio(dano)


func _ready() -> void:
	if hud:
		hud.actualizar_hp(hp, MAX_HP)
		hud.actualizar_exp(exp, EXP_POR_NIVEL[nivel], nivel)
	hp = MAX_HP
	hud = get_tree().get_first_node_in_group("hud")
	
	var vida = EsenciaVida.new()
	vida.activar()
	esencia_equipada_1 = vida
	add_child(vida)
	
	if hud:
		hud.actualizar_hp(hp, MAX_HP)

func ganar_exp(cantidad: int) -> void:
	exp += cantidad
	print("EXP: ", exp, " / ", EXP_POR_NIVEL[nivel])
	
	if hud:
		hud.actualizar_exp(exp, EXP_POR_NIVEL[nivel], nivel)
	
	if nivel < 20 and exp >= EXP_POR_NIVEL[nivel]:
		_subir_nivel()


func _subir_nivel() -> void:
	nivel += 1
	var hp_bonus = 20
	MAX_HP += hp_bonus
	hp = MAX_HP
	print("NIVEL ", nivel)
	
	if hud:
		hud.actualizar_hp(hp, MAX_HP)
		hud.actualizar_exp(0, EXP_POR_NIVEL[nivel], nivel)


func agregar_corrupcion(cantidad: int) -> void:
	corrupcion = min(corrupcion + cantidad, 100)
	print("Corrupcion: ", corrupcion)
