extends Control

# Declare member variables here. Examples:
var conf_menu
var Master_vol_midi = 14
var Loop_vol_midi = 15
var conf_file = "res://conf.cfg"

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

	OS.open_midi_inputs()
	for current_midi_input in OS.get_connected_midi_inputs():
		if current_midi_input in list_machine:
			var configFile = ConfigFile.new()
			configFile.load(conf_file)
			configFile.set_value("MACHINE", "active_machine", "res://model/"+str(current_midi_input)+".cfg")
			configFile.save(conf_file)
			print(current_midi_input)
			
	if OS.get_connected_midi_inputs().empty() == true:
		print("Device no detected")
		$noMidi.show()


func _process(_delta):
	if Input.is_action_just_released("record"):
		if $foot/ColorRect/Rec_Button.pressed == false:
			$foot/ColorRect/Rec_Button.pressed = true
		else:
			$foot/ColorRect/Rec_Button.pressed = false

func _on_edit_pressed():
	$PopupPanel.show()



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

# end of midi message
func _on_Timer_timeout():
	$noMidi.hide()
