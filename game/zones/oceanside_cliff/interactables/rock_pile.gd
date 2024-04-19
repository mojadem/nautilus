extends Node3D

const ROCK = preload("res://game/zones/oceanside_cliff/interactables/rock.tscn")

@onready var snap_zone: XRToolsSnapZone = $SnapZone


func _ready() -> void:
	snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)


func _on_snap_zone_has_dropped() -> void:
	var rock := ROCK.instantiate()
	snap_zone.add_child(rock)
	snap_zone.pick_up_object(rock)
