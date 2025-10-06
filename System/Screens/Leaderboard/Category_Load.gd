extends X8TextureButton

export  var category_num = 0

func _ready():
	pass
	

func on_press() -> void :
	menu.fetch_leaderboard(menu.categories[category_num])
