extends CanvasLayer

func actualizar_hp(hp_actual: int, hp_maximo: int) -> void:
	$MarginContainer/VBoxContainer/BarraHP.max_value = hp_maximo
	$MarginContainer/VBoxContainer/BarraHP.value = hp_actual
	$MarginContainer/VBoxContainer/LabelHP.text = "HP: " + str(hp_actual) + " / " + str(hp_maximo)

func actualizar_alma(alma_actual: int, alma_maxima: int) -> void:
	$MarginContainer/VBoxContainer/BarraAlma.max_value = alma_maxima
	$MarginContainer/VBoxContainer/BarraAlma.value = alma_actual
	$MarginContainer/VBoxContainer/LabelAlma.text = "Alma: " + str(alma_actual) + " / " + str(alma_maxima)
