extends Area2D

var activado = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Tekaya" and not activado:
		activado = true
		$ColorRect.color = Color("#FFFFFF")
		body.hp = body.MAX_HP
		if body.hud:
			body.hud.actualizar_hp(body.hp, body.MAX_HP)
		
		# Guarda la posición del altar como punto de reaparición
		body.punto_reaparicion = global_position
		print("Altar activado — HP restaurado al máximo")
