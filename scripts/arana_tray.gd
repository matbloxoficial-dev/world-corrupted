extends CharacterBody2D

const SPEED = 40.0
const GRAVITY = 980.0
const DANO = 8
const MAX_HP = 20
const COOLDOWN_ATAQUE = 2.0
const COOLDOWN_RED = 5.0
const RALENTIZACION = 0.4

enum Estado { PATRULLA, PERSECUCION, ATAQUE, MUERTO }

var estado = Estado.PATRULLA
var hp = MAX_HP
var facing = 1
var patrulla_timer = 3.0
var ataque_cooldown = 0.0
var red_cooldown = 0.0
var jugador = null

func _ready() -> void:
	$DetectionArea.body_entered.connect(_detectar_jugador)
	$DetectionArea.body_exited.connect(_perder_jugador)

func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTO:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if ataque_cooldown > 0:
		ataque_cooldown -= delta
	if red_cooldown > 0:
		red_cooldown -= delta

	match estado:
		Estado.PATRULLA:
			_patrullar(delta)
		Estado.PERSECUCION:
			_perseguir()
		Estado.ATAQUE:
			_atacar()

	move_and_slide()

func _patrullar(delta: float) -> void:
	patrulla_timer -= delta
	if patrulla_timer <= 0:
		facing *= -1
		patrulla_timer = 3.0
	velocity.x = SPEED * facing
	$ColorRect.modulate = Color("#6B2FA0")

func _perseguir() -> void:
	if jugador == null:
		estado = Estado.PATRULLA
		return

	var distancia = global_position.distance_to(jugador.global_position)
	if distancia <= 35:
		estado = Estado.ATAQUE
		return

	# Lanza red si está cerca y el cooldown lo permite
	if distancia <= 120 and red_cooldown <= 0:
		_lanzar_red()

	var direccion = sign(jugador.global_position.x - global_position.x)
	facing = direccion
	velocity.x = SPEED * direccion
	$ColorRect.modulate = Color("#8B3FC0")

func _atacar() -> void:
	if jugador == null:
		estado = Estado.PATRULLA
		return

	velocity.x = 0
	var distancia = global_position.distance_to(jugador.global_position)

	if distancia > 35:
		estado = Estado.PERSECUCION
		return

	if ataque_cooldown <= 0:
		jugador.recibir_danio(DANO)
		ataque_cooldown = COOLDOWN_ATAQUE
		print("Araña ataca — HP Tekaya: ", jugador.hp)

func _lanzar_red() -> void:
	red_cooldown = COOLDOWN_RED
	if jugador and jugador.has_method("aplicar_ralentizacion"):
		jugador.aplicar_ralentizacion(3.0)
		print("Araña lanza red — Tekaya ralentizado 3s")

func _esperar_y_restaurar() -> void:
	await get_tree().create_timer(3.0).timeout
	_restaurar_velocidad()

func _restaurar_velocidad() -> void:
	if is_instance_valid(jugador):
		jugador.SPEED_MODIFICADOR = 1.0
		print("Velocidad restaurada")

func _detectar_jugador(body: Node) -> void:
	if body.name == "Tekaya":
		jugador = body
		estado = Estado.PERSECUCION

func _perder_jugador(body: Node) -> void:
	if body.name == "Tekaya":
		jugador = null
		estado = Estado.PATRULLA

func recibir_danio(cantidad: int) -> void:
	hp -= cantidad
	print("Araña HP: ", hp, " / ", MAX_HP)
	if hp <= 0:
		morir()

func morir() -> void:
	estado = Estado.MUERTO
	if jugador and jugador.has_method("ganar_exp"):
		jugador.ganar_exp(20)
	if jugador and jugador.esencia_equipada_1 and jugador.esencia_equipada_1.has_method("ganar_alma"):
		jugador.esencia_equipada_1.ganar_alma(25, jugador)
	queue_free()
