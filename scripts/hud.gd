extends CanvasLayer

var barra_hp
var barra_alma
var barra_exp
var slot1
var slot2

func _ready() -> void:
	barra_hp = get_node("HUDIzquierda/ContenedorBarras/FilaHP/BarraHP")
	barra_alma = get_node("HUDIzquierda/ContenedorBarras/FilaAlma/BarraAlma")
	barra_exp = get_node("HUDIzquierda/ContenedorBarras/FilaEXP/BarraEXP")
	slot1 = get_node("HUDDerecha/EsenciaSlot1")
	slot2 = get_node("HUDDerecha/EsenciaSlot2")

func actualizar_hp(hp_actual: int, hp_maximo: int) -> void:
	if barra_hp:
		barra_hp.max_value = hp_maximo
		barra_hp.value = hp_actual

func actualizar_alma(alma_actual: int, alma_maxima: int) -> void:
	if barra_alma:
		barra_alma.max_value = alma_maxima
		barra_alma.value = alma_actual

func actualizar_exp(exp_actual: int, exp_necesaria: int, nivel_actual: int) -> void:
	if barra_exp:
		barra_exp.max_value = exp_necesaria
		barra_exp.value = exp_actual

func actualizar_esencia_slot1(color: Color) -> void:
	if slot1:
		slot1.color = color

func actualizar_esencia_slot2(color: Color) -> void:
	if slot2:
		slot2.color = color
