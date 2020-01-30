extends CanvasLayer

# Script da tela base

# Referencia ao Tween
onready var tween = $Tween

# Função para mostrar
func appear():
	# Habilita os botões
	get_tree().call_group("Buttons", "set_disabled", false)
	# Executa o tween
	tween.interpolate_property(self, "offset:x", 500, 0, 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

# Função para desaparecer
func disappear():
	# Desabilita os botões
	get_tree().call_group("Buttons", "set_disabled", true)
	# Executa o tween
	tween.interpolate_property(self, "offset:x", 0, 500, 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

# Função para abrir os links nos textos
func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)