extends EsenciaBase
class_name EsenciaVida

const CURACION_PULSO = 10
const RANGO_PULSO = 100.0
const REGENERACION_POR_SEGUNDO = 0.1

func _ready() -> void:
	nombre = "Esencia de Vida"

func habilidad_1(tekaya: Node) -> void:
	# Pulso Vital - cura a Tekaya
	var hp_anterior = tekaya.hp
	tekaya.hp = min(tekaya.hp + CURACION_PULSO, tekaya.MAX_HP)
	
	if tekaya.hud:
		tekaya.hud.actualizar_hp(tekaya.hp, tekaya.MAX_HP)
	
	print("Pulso Vital — curado: ", tekaya.hp - hp_anterior, " HP")

func pasiva(tekaya: Node, delta: float) -> void:
	# Resiliencia - regeneración lenta fuera de combate
	if not tekaya.atacando and tekaya.is_on_floor():
		if tekaya.hp < tekaya.MAX_HP:
			tekaya.hp = min(tekaya.hp + REGENERACION_POR_SEGUNDO * delta, tekaya.MAX_HP)
			if tekaya.hud:
				tekaya.hud.actualizar_hp(tekaya.hp, tekaya.MAX_HP)
