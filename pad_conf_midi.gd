extends WindowDialog

var conf_machine = ""
var conf_file = "res://conf.cfg"
var pad = 16


func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")
	$CenterMidi/GridContainer.columns = pad/4
	for bt in pad:
		var testbt = Button.new()
		#testbt.margin_top = 30
		#testbt.margin_bottom = 30
		testbt.text = "test"+str(bt)
		testbt.name = "pad"+str(bt)
		$CenterMidi/GridContainer.add_child(testbt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
