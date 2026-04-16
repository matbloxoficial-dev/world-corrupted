extends Node
class_name EsenciaBase

@export var nombre: String = ""
@export var activa: bool = false

func activar() -> void:
	activa = true
	print(nombre, " equipada")

func desactivar() -> void:
	activa = false

func habilidad_1(tekaya: Node) -> void:
	pass

func habilidad_2(tekaya: Node) -> void:
	pass

func habilidad_3(tekaya: Node) -> void:
	pass

func pasiva(tekaya: Node, delta: float) -> void:
	pass
