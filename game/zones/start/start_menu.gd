extends Control


func _ready() -> void:
	%Play.pressed.connect(_on_play_pressed)
	%Level.pressed.connect(_on_level_pressed)
	%Credits.pressed.connect(_on_credits_pressed)
	%Quit.pressed.connect(_on_quit_pressed)
	%FuneralReception.pressed.connect(_on_funeral_reception_pressed)
	%OceansideCliff.pressed.connect(_on_oceanside_cliff_pressed)
	%ForestLake.pressed.connect(_on_forest_lake_pressed)
	%Back.pressed.connect(_on_back_pressed)


func load_scene(path: String, user_data = null) -> void:
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	scene_base.load_scene(path, user_data)


func _on_play_pressed() -> void:
	load_scene("res://game/zones/living_room/living_room_1.tscn")


func _on_level_pressed() -> void:
	%TabContainer.current_tab = 1


func _on_credits_pressed() -> void:
	load_scene("res://game/zones/credits/credits.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_funeral_reception_pressed() -> void:
	load_scene("res://game/zones/funeral_reception/funeral_reception.tscn", {"selected": true})


func _on_oceanside_cliff_pressed() -> void:
	load_scene("res://game/zones/oceanside_cliff/oceanside_cliff.tscn", {"selected": true})


func _on_forest_lake_pressed() -> void:
	load_scene("res://game/zones/forest_lake/forest_lake.tscn", {"selected": true})


func _on_back_pressed() -> void:
	%TabContainer.current_tab = 0
