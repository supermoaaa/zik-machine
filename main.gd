extends Control

# Declare member variables here. Examples:
var conf_menu
var Master_vol_midi = 14
var Loop_vol_midi = 15

func get_conf_list(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(str(file).get_basename ())

	dir.list_dir_end()

	return files

func _ready():
	
	var list_machine = get_conf_list("res://model/")
	print(list_machine)
	OS.open_midi_inputs()
	for current_midi_input in OS.get_connected_midi_inputs():
		if current_midi_input in list_machine:
			print(current_midi_input)
	
	#var songs = get_tree().get_nodes_in_group("song")
	#for song in songs:
		#print(song.get_stream())

	pass


func _on_edit_pressed():
	$PopupPanel.show()

	pass # Replace with function body.


func _on_exit_pressed():
	$PopupPanel.hide()


func _on_quit_pressed():
	get_tree().quit()

#master volume
func _on_VSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

enum GlobalScope_MidiMessageList {
	MIDI_MESSAGE_NOTE_OFF = 0x8,
	MIDI_MESSAGE_NOTE_ON = 0x9,
	MIDI_MESSAGE_AFTERTOUCH = 0xA,
	MIDI_MESSAGE_CONTROL_CHANGE = 0xB,
	MIDI_MESSAGE_PROGRAM_CHANGE = 0xC,
	MIDI_MESSAGE_CHANNEL_PRESSURE = 0xD,
	MIDI_MESSAGE_PITCH_BEND = 0xE,
};

func get_midi_message_description(event : InputEventMIDI):
	if GlobalScope_MidiMessageList.values().has(event.message):
		return GlobalScope_MidiMessageList.keys()[event.message - 0x08]
	#print(event.message)


func _unhandled_input(event : InputEvent):
	if (event is InputEventMIDI):
		
		if event.controller_number == Master_vol_midi:

			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (event.controller_value *0.78)-80)
			get_node("foot/ColorRect/MasterRect/Master_vol").value = (event.controller_value *0.78)-80
		
		if event.controller_number == Loop_vol_midi:

			get_node("foot/ColorRect/loopPanel/loop_stream").volume_db = (event.controller_value *0.78)-80
			get_node("foot/ColorRect/loopPanel/loopVolume").value = (event.controller_value *0.78)-80
