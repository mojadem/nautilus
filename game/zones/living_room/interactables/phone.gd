extends Node3D

@onready var buttons: Array[XRToolsInteractableAreaButton] = [
	$Buttons/Button0, 
	$Buttons/Button1, 
	$Buttons/Button2, 
	$Buttons/Button3, 
	$Buttons/Button4, 
	$Buttons/Button5, 
	$Buttons/Button6, 
	$Buttons/Button7, 
	$Buttons/Button8, 
	$Buttons/Button9
]


func _ready() -> void:
	for button in buttons:
		button.button_pressed.connect(_on_button_pressed)


func _on_button_pressed(button: Variant) -> void:
	print(button)
