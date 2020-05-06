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
		$savepreset.current_file = current_midi_input + ".cfg"


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
	
