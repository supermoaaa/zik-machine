extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_compress_on_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_effect_enabled ( 0, 2, true )
		$compress_on.text = "off"
	else:
		AudioServer.set_bus_effect_enabled ( 0, 2, false )
		$compress_on.text = "on"


func _on_HSlider_gain_value_changed(value):
	AudioServer.get_bus_effect(0, 2).set_gain(value)


func _on_HSlider_mix_value_changed(value):
	AudioServer.get_bus_effect(0, 2).set_mix(value)


func _on_HSlider_value_changed(value):
	AudioServer.get_bus_effect(0, 2).set_attack_us(value)
