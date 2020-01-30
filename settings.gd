extends Node

var score_file = "user://highscore.save"
var settings_file = "user://settings.save"
var enable_sound = true
var enable_music = true

var circles_per_level = 5

var color_schemes = {
	"NEON1": {
		"background": Color8(0, 0, 0),
		"player_body": Color8(203, 255, 0),
		"player_trail": Color8(204, 0, 255),
		"circle_fill": Color8(255, 0, 110),
		"circle_static": Color8(0, 255, 102),
		"circle_limited": Color8(204, 0, 255)
	},
	"NEON2": {
		"background": Color8(0, 0, 0),
		"player_body": Color8(246, 255, 0),
		"player_trail": Color8(255, 255, 255),
		"circle_fill": Color8(255, 0, 110),
		"circle_static": Color8(151, 255, 48),
		"circle_limited": Color8(127, 0, 255)
	},
	"NEON3": {
		"background": Color8(0, 0, 0),
		"player_body": Color8(255, 0, 187),
		"player_trail": Color8(255, 148, 0),
		"circle_fill": Color8(255, 148, 0),
		"circle_static": Color8(170, 255, 0),
		"circle_limited": Color8(204, 0, 255)
	}
}

var theme = color_schemes["NEON2"]

static func rand_weighted(weights):
	var sum = 0
	for weight in weights:
		sum+=weight
	var num = rand_range(0, sum)
	for i in weights.size():
		if num < weights[i]:
			return i
		num -= weights[i]

var admob = null
# Change to true when publishing
var real_ads = true
# Define se o banner fica em cima
var banner_top = false
# IDS
var ad_banner_id = "ca-app-pub-3861926147580208/1927380872"
var ad_interstitial_id = "ca-app-pub-3861926147580208/9558937813"
# Define se pode mostrar ADs
var enable_ads = true setget set_enable_ads

func _ready():
	# Carrega as configs
	load_settings()
	# Verifica se o AdMob existe
	if Engine.has_singleton("AdMob"):
		# Cria uma referencia
		admob = Engine.get_singleton("AdMob")
		# Inicia com as configs e a instancia
		admob.init(real_ads, get_instance_id())
		# Carrega o banner
		admob.loadBanner(ad_banner_id, banner_top)
		# Carrega o intersticial
		admob.loadInterstitial(ad_interstitial_id)
		

# Mostra o banner se possivel
func show_ad_banner():
	if admob and enable_ads:
		admob.showBanner()
		
# Esconde o banner
func hide_ad_banner():
	if admob:
		admob.hideBanner()

# Mostra o intersticial se possivel
func show_ad_interstitial():
	if admob and enable_ads:
		admob.showInterstitial()

# Mostra o banner ao fechar o intersticial
func _on_interstitial_closed():
	if admob and enable_ads:
		show_ad_banner()

# Seta o valor e mostra o banner conforme
func set_enable_ads(value):
	enable_ads = value
	if enable_ads:
		show_ad_banner()
	if !enable_ads:
		hide_ad_banner()
	save_settings()

# Salva as configs
func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var(enable_sound)
	f.store_var(enable_music)
	f.store_var(enable_ads)
	f.close()

# Carrega as configs
func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		enable_sound = f.get_var()
		enable_music = f.get_var()
		self.enable_ads = f.get_var()
		f.close()
