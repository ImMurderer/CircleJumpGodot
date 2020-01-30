extends Node

var Circle = load("res://Objects/Circle.tscn")
var Jumper = load("res://Objects/Jumper.tscn")

var player
var score = 0 setget set_score
var num_circles
var highscore = 0
var new_highscore = false
var level = 0

var bonus = 0 setget set_bonus

func _ready():
	# Gera uma seed nova
	randomize()
	# Carrega o score
	load_score()
	# Esconde a HUD
	$HUD.hide()
	
func new_game():
	new_highscore = false
	# Esconde o banner de anuncio
	settings.hide_ad_banner()
	self.score = 0
	self.bonus = 0
	num_circles = 0
	level = 1
	# Reseta o score
	$HUD.update_score(score, 0)
	#Define a posição inicial da camera
	$Camera2D.position = $StartPosition.position
	# Cria uma instancia do player
	player = Jumper.instance()
	# Coloca o player na posição inicial
	player.position = $StartPosition.position
	# Coloca o player na cena
	add_child(player)
	# Conecta os signals
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
	# Cria um circulo na posição inicial
	spawn_circle($StartPosition.position)
	# Mostra o HUD e toca a musica
	$HUD.show()
	$HUD.show_message("Go!")
	if settings.enable_music:
		$Music.volume_db = 0
		$Music.play()

func spawn_circle(_position = null):
	# Cria uma nova instancia do player
	var c = Circle.instance()
	# Se não tiver posição predefinida
	if !_position:
		# Randomiza x e y
		var x = rand_range(-150, 150)
		var y = rand_range(-500, -400)
		# Seta o posição em relação ao player
		_position = player.target.position + Vector2(x, y)
	# Coloca o circulo na cena
	add_child(c)
	# Conecta o sinal
	c.connect("full_orbit", self, "set_bonus", [1])
	# Inicia o circulo
	c.init(_position, level)
	
	
func _on_Jumper_captured(object):
	self.score += 1 * bonus
	self.bonus += 1
	num_circles += 1
	if num_circles > 0 and num_circles % settings.circles_per_level == 0:
		level += 1
		$HUD.show_message("Level %s" % str(level))
	$Camera2D.position = object.position
	object.capture(player)
	call_deferred("spawn_circle")
	
# Função pra setar o score
func set_score(value):
	# Atualiza a HUD
	$HUD.update_score(score, value)
	score=value
	# Se ultrapassar o recorde avisa o player na HUD
	if score > highscore and !new_highscore:
		$HUD.show_message("New Record!")
		new_highscore = true

# Signal que verifica se o player morreu
func _on_Jumper_died():
	# Se o score for maior que o highscore
	if score > highscore:
		# Define o novo highscore e salva
		highscore = score
		save_score()
	# Destroi todos os circulos
	get_tree().call_group("Circles", "implode")
	# Para a musica
	fade_music() if settings.enable_music else 0
	# Chama a cena de game_over com os scores
	$Screens.game_over(score, highscore)
	# Esconde a HUD
	$HUD.hide()
	# Mostra o anúncio
	settings.show_ad_interstitial()
	
	
# Funções para salvar o score
# Carrega o score
func load_score():
	# Instancia uma classe File para tratar arquivos
	var f = File.new()
	# Se o arquivo ja existir
	if f.file_exists(settings.score_file):
		# Abre
		f.open(settings.score_file, File.READ)
		# Pega o valor do highscore
		highscore = f.get_var()
		# Fecha
		f.close()

# Salva o score
func save_score():
	var f = File.new()
	f.open(settings.score_file, File.WRITE)
	# Armazena o highscore no arquivo
	f.store_var(highscore)
	f.close()


# Função que suaviza a saida da musica
func fade_music():
	# Usa um Tween para interpolar o volume
	$MusicFade.interpolate_property($Music, "volume_db",
		0, -50, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	# Inicia o Tween
	$MusicFade.start()
	# Espera o Tween terminar
	yield($MusicFade, "tween_all_completed")
	# Para a música
	$Music.stop()


# Funcao pra setar o bonus
func set_bonus(value):
	bonus = value
	# Atualiza o HUD
	$HUD.update_bonus(bonus)