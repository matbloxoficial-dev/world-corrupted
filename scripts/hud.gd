extends CanvasLayer

func actualizar_hp(hp_actual: int, hp_maximo: int) -> void:
	$MarginContainer/VBoxContainer/BarraHP.max_value = hp_maximo
	$MarginContainer/VBoxContainer/BarraHP.value = hp_actual
	$MarginContainer/VBoxContainer/LabelHP.text = "HP: " + str(hp_actual) + " / " + str(hp_maximo)
