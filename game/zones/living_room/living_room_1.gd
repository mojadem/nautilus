extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var phone_ring: AudioStreamPlayer3D = $Interactables/Phone/AudioStreamPlayer3D
@onready var phone: XRToolsPickable = $Interactables/Phone/Phone
@onready var mc_dialog: AudioStreamPlayer3D = $XROrigin3D/XRCamera3D/AudioStreamPlayer3D
@onready var funeral_card: RigidBody3D = $Interactables/FuneralCard

enum State {
	INITIAL,
	PHONE_RINGING,
	PHONE_CALL,
	POST_PHONE_CALL,
	PHONE_HANGUP,
}

var state := State.INITIAL


func _on_phone_ring_delay_timeout() -> void:
	state = State.PHONE_RINGING
	phone_ring.play()
	phone.enabled = true
	var mesh: MeshInstance3D = phone.get_node("MeshInstance3D")
	mesh.get_active_material(0).next_pass.set_shader_param("enabled", true)


func _on_snap_zone_has_dropped():
	if state == State.PHONE_RINGING:
		state = State.PHONE_CALL
		phone_ring.stop()
		animation_player.play("phone_call")
		var mesh: MeshInstance3D = phone.get_node("MeshInstance3D")
		mesh.get_active_material(0).next_pass.set_shader_param("enabled", false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == State.PHONE_CALL:
		assert(anim_name == "phone_call")
		state = State.POST_PHONE_CALL


func _on_snap_zone_has_picked_up(_what: Variant) -> void:
	if state == State.POST_PHONE_CALL:
		state = State.PHONE_HANGUP
		mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/6.wav")
		mc_dialog.play()
		funeral_card.enabled = true


func _on_funeral_card_picked_up(pickable: Variant) -> void:
	assert(state == State.PHONE_HANGUP)
	mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/7.wav")
	mc_dialog.play()
