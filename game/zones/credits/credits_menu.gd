extends Control

@export var scrolling: bool = false
@export var scroll_speed: float = 128


func _ready() -> void:
	%EndTimer.timeout.connect(_on_end_timer_timeout)
	%ScrollContainer.scroll_vertical = 0
	scrolling = true


func _process(delta: float) -> void:
	if not scrolling:
		return
	
	%ScrollContainer.scroll_vertical += int(scroll_speed * delta)
	
	if %ScrollContainer.scroll_vertical >= 3045:
		%EndTimer.start()
		scrolling = false


func _on_end_timer_timeout() -> void:
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	scene_base.load_scene("res://game/zones/start/start.tscn")
