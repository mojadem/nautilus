extends AudioStreamPlayer3D

@export_dir var base_dir

var dir: DirAccess
var current: String


func _ready():
	dir = DirAccess.open(base_dir)
	dir.list_dir_begin()
	current = dir.get_next()
	stream.load(current)


func _on_finished():
	current = dir.get_next()
	if current != "":
		stream.load(current)
