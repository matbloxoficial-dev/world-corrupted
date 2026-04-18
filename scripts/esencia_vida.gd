extends EsenciaBase
class_name EsenciaVida

const CURACION_PULSO = 10
const REGENERACION_POR_SEGUNDO = 0.0001
const COSTO_PULSO = 100
const MAX_ALMA = 100

var alma = 0

func _ready() -> void:
	nombre = "Esencia de Vida"

func habilidad_1(tekaya: Node) -> void:
	if alma < COSTO_PULSO:
		print("Sin alma suficiente: ", alma, " / ", COSTO_PULSO)
		return
	
	alma -= COSTO_PULSO
	var hp_anterior = tekaya.hp
	tekaya.hp = min(tekaya.hp + CURACION_PULSO, tekaya.MAX_HP)
	
	if tekaya.hud:
		tekaya.hud.actualizar_hp(tekaya.hp, tekaya.MAX_HP)
	
	print("Pulso Vital — curado: ", tekaya.hp - hp_anterior, " HP | Alma: ", alma, " / ", MAX_ALMA)

func ganar_alma(cantidad: int) -> void:
	alma = min(alma + cantidad, MAX_ALMA)
	print("Alma: ", alma, " / ", MAX_ALMA)

func pasiva(tekaya: Node, delta: float) -> void:
	if not tekaya.atacando and tekaya.is_on_floor():
		if tekaya.hp < tekaya.MAX_HP:
			tekaya.hp = min(tekaya.hp + REGENERACION_POR_SEGUNDO * delta, tekaya.MAX_HP)
			if tekaya.hud:
				tekaya.hud.actualizar_hp(tekaya.hp, tekaya.MAX_HP)
