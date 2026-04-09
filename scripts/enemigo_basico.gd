extends CharacterBody2D

const SPEED_PATRULLA = 60.0
const SPEED_PERSECUCION = 120.0
const GRAVITY = 980.0
const DANO = 10
const MAX_HP = 30
const DISTANCIA_ATAQUE = 40.0
const COOLDOWN_ATAQUE = 1.5

enum Estado { PATRULLA, PERSECUCION, ATAQUE, MUERTO }

var estado = Estado.PATRULLA
var hp = MAX_HP
var facing = 1
var patrulla_timer = 2.0
var ataque_cooldown = 0.0
var jugador = null

func _ready() -> void:
	$DetectionArea.body_entered.connect(_detectar_jugador)
	$DetectionArea.body_exited.connect(_perder_jugador)

func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTO:
		return

	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if ataque_cooldown > 0:
		ataque_cooldown -= delta

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
		patrulla_timer = 2.0

	velocity.x = SPEED_PATRULLA * facing
	$ColorRect.modulate = Color.RED

func _perseguir() -> void:
	if jugador == null:
		estado = Estado.PATRULLA
		return

	var distancia = global_position.distance_to(jugador.global_position)

	if distancia <= DISTANCIA_ATAQUE:
		estado = Estado.ATAQUE
		return

	var direccion = sign(jugador.global_position.x - global_position.x)
	facing = direccion
	velocity.x = SPEED_PERSECUCION * direccion
	$ColorRect.modulate = Color.ORANGE

func _atacar() -> void:
	if jugador == null:
		estado = Estado.PATRULLA
		return

	velocity.x = 0
	var distancia = global_position.distance_to(jugador.global_position)

	if distancia > DISTANCIA_ATAQUE:
		estado = Estado.PERSECUCION
		return

	if ataque_cooldown <= 0:
		jugador.recibir_danio(DANO)
		ataque_cooldown = COOLDOWN_ATAQUE
		print("Enemigo ataca — HP Tekaya: ", jugador.hp)
		$ColorRect.modulate = Color.DARK_RED

func _detectar_jugador(body: Node) -> void:
	if body.name == "Tekaya":
		jugador = body
		estado = Estado.PERSECUCION
		print("Enemigo detecta a Tekaya")

func _perder_jugador(body: Node) -> void:
	if body.name == "Tekaya":
		jugador = null
		estado = Estado.PATRULLA
		print("Enemigo pierde de vista a Tekaya")

func recibir_danio(cantidad: int) -> void:
	hp -= cantidad
	print("Enemigo HP: ", hp, " / ", MAX_HP)
	if hp <= 0:
		morir()

func morir() -> void:
	estado = Estado.MUERTO
	print("Enemigo muerto")
	queue_free()
