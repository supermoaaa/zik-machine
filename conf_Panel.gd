extends WindowDialog


# Declare member variables here. Examples:
var conf_file = "res://conf.cfg"
var conf_machine


# Called when the node enters the scene tree for the first time.
func _ready():

	$Pad_Number_opt.add_item("4 pad")
	$Pad_Number_opt.add_item("8 pad")
	$Pad_Number_opt.add_item("16 pad")
	
	$bank.add_item("none")
	$bank.add_item("2")
	$bank.add_item("3")
	$bank.add_item("4")
	$bank.add_item("5")
	$bank.add_item("6")
	$bank.add_item("7")
	$bank.add_item("8")
	
	var configFile = ConfigFile.new()
	configFile.load(conf_file) 
	$output_dir.text = "OUTPUT FOLDER: " + str(configFile.get_value("OUTPUT", "song_save_path"))
	
	conf_machine = configFile.get_value("MACHINE", "active_machine")
	#print(str(conf_machine))
	configFile.load(conf_machine)
	var pad_number = configFile.get_value("PAD CONF", "PAD_number")
	if pad_number == 4:
		$Pad_Number_opt.select(0)
	elif pad_number == 8:
		$Pad_Number_opt.select(1)
	elif pad_number == 16:
		$Pad_Number_opt.select(2)	
	
	OS.open_midi_inputs()
	for current_midi_input in OS.get_connected_midi_inputs():
		$controlleurName.text = current_midi_input
		#$savepreset.current_file = current_midi_input + ".cfg"
	OS.close_midi_inputs()
	$sound_driver.text = OS.get_audio_driver_name(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_output_change_pressed():
	$FileDialog.show()


func _on_FileDialog_dir_selected(dir):
	print(dir)
	var configFile = ConfigFile.new()
	configFile.load(conf_file) 
	configFile.set_value("OUTPUT", "song_save_path", dir)
	configFile.save(conf_file)
	$output_dir.text = "OUTPUT: " + str(dir)
	$FileDialog.hide()




func _on_Pad_Number_opt_item_selected(id):
	var configFile = ConfigFile.new()
	configFile.load(conf_machine)
	if id == 0:
		configFile.set_value("PAD CONF","PAD_number",4)
	elif id == 1:
		configFile.set_value("PAD CONF","PAD_number",8)
	elif id == 2:
		configFile.set_value("PAD CONF","PAD_number",16)
		
	configFile.save(conf_machine)

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
	return(event.message)

	
func _unhandled_input(event : InputEvent):

	if (event is InputEventMIDI):
		var key_index = event.pitch
		$detected_midi_lab.text = "midi button detected:" + str(key_index)


func _on_bank_item_selected(index):
	var configFile = ConfigFile.new()
	configFile.load(conf_machine)
	configFile.set_value("PAD CONF","BANK_number",str(index+1))
	configFile.save(conf_machine)


func _on_pad_conf_pressed():
	$pad_conf_panel.visible= true


func _on_Button_close_pressed():
	$pad_conf_panel.visible= false
