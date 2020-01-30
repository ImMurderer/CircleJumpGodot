extends Node

signal start_game

var sound_buttons = {true: load("res://assets/images/buttons/audioOn.png"),
	false: load("res://assets/images/buttons/audioOff.png")}
var music_buttons = {true: load("res://assets/images/buttons/musicOn.png"),
	false: load("res://assets/images/buttons/musicOff.png")}
	
var current_screen = null

func _ready():
	# Coloca as funções nos botões
	register_buttons()
	# Muda pra tela inicial
	change_screen($TitleScreen)
	

# Registra os botões
func register_buttons():
	# Pega todos os nós no grupo Buttons
	var buttons = get_tree().get_nodes_in_group("Buttons")
	# Itera sobre os botões
	for button in buttons:
		# Conecta o signal e passa o botão como argumento
		button.connect("pressed", self, "_on_button_pressed", [button])
		# Define a situação dos botões conforme o settings
		match button.name:
			"Ads":
				if settings.enable_ads:
					button.text = "Disable Ads"
				else:
					button.text = "Enable Ads"
			"Sound":
				button.texture_normal = sound_buttons[settings.enable_sound]
			"Music":
				button.texture_normal = music_buttons[settings.enable_music]

# Função que lida com o signal pressed do botão
func _on_button_pressed(button):
	$Click.play() if settings.enable_sound else 0
	match button.name:
		# Botões da tela inicial
		"About":
			change_screen($AboutScreen)
		"Home":
			change_screen($TitleScreen)
		"Play":
			# Tira a tela atual
			change_screen(null)
			# Delay para facilitar a mudança de tela
			yield(get_tree().create_timer(0.5), "timeout")
			# Emite o sinal para começar um jogo novo
			emit_signal("start_game")
		"Settings":
			change_screen($SettingsScreen)
		# Botões de settings, salvam a config ao alterar
		"Sound":
			settings.enable_sound = !settings.enable_sound
			button.texture_normal = sound_buttons[settings.enable_sound]
			settings.save_settings()
		"Music":
			settings.enable_music = !settings.enable_music
			button.texture_normal = music_buttons[settings.enable_music]
			settings.save_settings()
		"Ads":
			settings.enable_ads = !settings.enable_ads
			if settings.enable_ads:
				button.text = "Disable Ads"
			else:
				button.text = "Enable Ads"

# Função pra trocar de telas
func change_screen(new_screen):
	# Se ja existir uma tela
	if current_screen:
		# Desaparece
		current_screen.disappear()
		# Espera terminar
		yield(current_screen.tween, "tween_completed")
	current_screen = new_screen
	# Se tiver uma nova tela
	if new_screen:
		# Mostra
		current_screen.appear()
		# Espera terminar
		yield(current_screen.tween, "tween_completed")
	

# Função de gameover
func game_over(score, highscore):
	# Referencia o score-box
	var score_box = $GameOverScreen/MarginContainer/VBoxContainer/Scores
	# Seta os textos
	score_box.get_node("Score").text = "Score: %s" % score
	score_box.get_node("Best").text = "Best: %s" % highscore
	# Muda pra tela de game over
	change_screen($GameOverScreen)