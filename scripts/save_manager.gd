extends Node

const RUTA_GUARDADO = "user://savegame.cfg"

func guardar(tekaya: Node) -> void:
	var config = ConfigFile.new()
	
	config.set_value("jugador", "nivel", tekaya.nivel)
	config.set_value("jugador", "exp", tekaya.exp)
	config.set_value("jugador", "hp", tekaya.hp)
	config.set_value("jugador", "max_hp", tekaya.MAX_HP)
	config.set_value("jugador", "corrupcion", tekaya.corrupcion)
	config.set_value("jugador", "punto_reaparicion_x", tekaya.punto_reaparicion.x)
	config.set_value("jugador", "punto_reaparicion_y", tekaya.punto_reaparicion.y)
	
	if tekaya.esencia_equipada_1:
		config.set_value("esencias", "alma", tekaya.esencia_equipada_1.alma)
	
	config.save(RUTA_GUARDADO)
	print("Partida guardada")

func cargar(tekaya: Node) -> bool:
	var config = ConfigFile.new()
	var error = config.load(RUTA_GUARDADO)
	
	if error != OK:
		print("No hay partida guardada")
		return false
	
	tekaya.nivel = config.get_value("jugador", "nivel", 1)
	tekaya.exp = config.get_value("jugador", "exp", 0)
	tekaya.MAX_HP = config.get_value("jugador", "max_hp", 80)
	tekaya.hp = config.get_value("jugador", "hp", tekaya.MAX_HP)
	tekaya.corrupcion = config.get_value("jugador", "corrupcion", 0)
	
	var rep_x = config.get_value("jugador", "punto_reaparicion_x", 0)
	var rep_y = config.get_value("jugador", "punto_reaparicion_y", 0)
	tekaya.punto_reaparicion = Vector2(rep_x, rep_y)
	
	if tekaya.esencia_equipada_1:
		tekaya.esencia_equipada_1.alma = config.get_value("esencias", "alma", 0)
	
	print("Partida cargada — Nivel: ", tekaya.nivel, " | EXP: ", tekaya.exp)
	return true
